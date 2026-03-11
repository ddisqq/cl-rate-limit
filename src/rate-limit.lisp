;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: BSD-3-Clause

;;;; rate-limit.lisp
;;;; Token bucket rate limiter implementation

(in-package #:cl-rate-limit)

;;; Conditions

(define-condition rate-limit-exceeded (error)
  ((limiter :initarg :limiter :reader rate-limit-exceeded-limiter))
  (:report (lambda (c s)
             (format s "Rate limit exceeded for limiter ~A"
                     (rate-limiter-name (rate-limit-exceeded-limiter c))))))

(define-condition rate-limit-timeout (error)
  ((limiter :initarg :limiter :reader rate-limit-timeout-limiter)
   (timeout :initarg :timeout :reader rate-limit-timeout-seconds))
  (:report (lambda (c s)
             (format s "Rate limit acquisition timed out after ~A seconds"
                     (rate-limit-timeout-seconds c)))))

;;; Rate Limiter Structure

(defstruct (rate-limiter (:constructor %make-rate-limiter))
  "A token bucket rate limiter."
  (name "default" :type string)
  (capacity 10.0 :type single-float)          ; max tokens
  (refill-rate 1.0 :type single-float)        ; tokens per second
  (tokens 10.0 :type single-float)            ; current tokens
  (last-refill 0 :type (unsigned-byte 64)))   ; internal-real-time

(defun make-rate-limiter (capacity refill-rate &key (name "default"))
  "Create a rate limiter with CAPACITY tokens and REFILL-RATE tokens/second."
  (%make-rate-limiter :name name
                      :capacity (coerce capacity 'single-float)
                      :refill-rate (coerce refill-rate 'single-float)
                      :tokens (coerce capacity 'single-float)
                      :last-refill (get-internal-real-time)))

;;; Token Management

(defun refill-tokens (limiter)
  "Refill tokens based on elapsed time since last refill."
  (let* ((now (get-internal-real-time))
         (elapsed-time (/ (- now (rate-limiter-last-refill limiter))
                          internal-time-units-per-second))
         (new-tokens (+ (rate-limiter-tokens limiter)
                        (* elapsed-time (rate-limiter-refill-rate limiter)))))
    (setf (rate-limiter-tokens limiter)
          (min new-tokens (rate-limiter-capacity limiter)))
    (setf (rate-limiter-last-refill limiter) now)))

(defun tokens-available (limiter)
  "Return the number of tokens currently available."
  (refill-tokens limiter)
  (rate-limiter-tokens limiter))

(defun bucket-capacity (limiter)
  "Return the maximum capacity of the token bucket."
  (rate-limiter-capacity limiter))

(defun refill-rate (limiter)
  "Return the refill rate in tokens per second."
  (rate-limiter-refill-rate limiter))

;;; Token Acquisition

(defun try-acquire (limiter &optional (tokens 1))
  "Try to acquire TOKENS from LIMITER.
   Returns T if successful, NIL if not enough tokens."
  (refill-tokens limiter)
  (let ((current (rate-limiter-tokens limiter)))
    (if (>= current tokens)
        (progn
          (setf (rate-limiter-tokens limiter) (- current tokens))
          t)
        nil)))

(defun acquire (limiter &key (tokens 1) (timeout nil) (poll-interval 0.01))
  "Acquire TOKENS from LIMITER, blocking if necessary.
   If TIMEOUT is specified (in seconds), may raise RATE-LIMIT-TIMEOUT.
   POLL-INTERVAL specifies how often to check for available tokens."
  (let ((start-time (get-internal-real-time)))
    (loop
      (when (try-acquire limiter tokens)
        (return t))
      (when timeout
        (let ((elapsed (/ (- (get-internal-real-time) start-time)
                          internal-time-units-per-second)))
          (when (>= elapsed timeout)
            (error 'rate-limit-timeout
                   :limiter limiter
                   :timeout timeout))))
      (sleep poll-interval))))

(defun release (limiter &optional (tokens 1))
  "Release TOKENS back to LIMITER (up to capacity)."
  (setf (rate-limiter-tokens limiter)
        (min (rate-limiter-capacity limiter)
             (+ (rate-limiter-tokens limiter) tokens))))

;;; Context Macro

(defmacro with-rate-limit ((limiter &key (tokens 1) timeout on-exceeded) &body body)
  "Execute BODY if tokens can be acquired from LIMITER.

   :tokens - Number of tokens to acquire (default: 1)
   :timeout - Seconds to wait for tokens (NIL = non-blocking check)
   :on-exceeded - Form to evaluate if rate limit exceeded (default: signal error)"
  (let ((lim (gensym "LIMITER"))
        (tok (gensym "TOKENS"))
        (acquired (gensym "ACQUIRED")))
    `(let* ((,lim ,limiter)
            (,tok ,tokens)
            (,acquired ,(if timeout
                            `(handler-case
                                 (progn (acquire ,lim :tokens ,tok :timeout ,timeout) t)
                               (rate-limit-timeout () nil))
                            `(try-acquire ,lim ,tok))))
       (if ,acquired
           (progn ,@body)
           ,(or on-exceeded
                `(error 'rate-limit-exceeded :limiter ,lim))))))
