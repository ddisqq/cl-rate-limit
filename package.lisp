;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0

;;;; package.lisp
;;;; Package definition for cl-rate-limit

(defpackage #:cl-rate-limit
  (:use #:cl)
  (:export
   ;; Rate limiter type and constructor
   #:rate-limiter
   #:make-rate-limiter
   ;; Token operations
   #:try-acquire
   #:acquire
   #:release
   ;; State inspection
   #:tokens-available
   #:refill-rate
   #:bucket-capacity
   ;; Context macro
   #:with-rate-limit
   ;; Configuration
   #:rate-limiter-capacity
   #:rate-limiter-refill-rate
   #:rate-limiter-tokens
   ;; Conditions
   #:rate-limit-exceeded
   #:rate-limit-timeout))
