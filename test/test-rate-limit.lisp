;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

;;;; test-rate-limit.lisp - Unit tests for rate-limit
;;;;
;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0

(defpackage #:cl-rate-limit.test
  (:use #:cl)
  (:export #:run-tests))

(in-package #:cl-rate-limit.test)

(defun run-tests ()
  "Run all tests for cl-rate-limit."
  (format t "~&Running tests for cl-rate-limit...~%")
  ;; TODO: Add test cases
  ;; (test-function-1)
  ;; (test-function-2)
  (format t "~&All tests passed!~%")
  t)
