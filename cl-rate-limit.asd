;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; cl-rate-limit.asd
;;;; Token bucket rate limiter with zero external dependencies

(asdf:defsystem #:cl-rate-limit
  :description "Pure Common Lisp token bucket rate limiter library"
  :author "Parkian Company LLC"
  :license "Apache-2.0"
  :version "0.1.0"
  :serial t
  :components ((:file "package")
               (:module "src"
                :serial t
                :components ((:file "rate-limit")))))

(asdf:defsystem #:cl-rate-limit/test
  :description "Tests for cl-rate-limit"
  :depends-on (#:cl-rate-limit)
  :serial t
  :components ((:module "test"
                :components ((:file "test-rate-limit"))))
  :perform (asdf:test-op (o c)
             (let ((result (uiop:symbol-call :cl-rate-limit.test :run-tests)))
               (unless result
                 (error "Tests failed")))))
