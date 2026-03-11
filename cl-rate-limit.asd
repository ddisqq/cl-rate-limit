;;;; cl-rate-limit.asd
;;;; Token bucket rate limiter with zero external dependencies

(asdf:defsystem #:cl-rate-limit
  :description "Pure Common Lisp token bucket rate limiter library"
  :author "Parkian Company LLC"
  :license "BSD-3-Clause"
  :version "1.0.0"
  :serial t
  :components ((:file "package")
               (:module "src"
                :serial t
                :components ((:file "rate-limit")))))
