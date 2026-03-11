# cl-rate-limit

Pure Common Lisp token bucket rate limiter library with zero external dependencies.

## Installation

```lisp
(asdf:load-system :cl-rate-limit)
```

## Usage

```lisp
(use-package :cl-rate-limit)

;; Create a rate limiter (10 requests/second, burst of 20)
(let ((limiter (make-rate-limiter 20 10.0)))

  ;; Non-blocking acquire
  (when (try-acquire limiter)
    (process-request))

  ;; Blocking acquire
  (acquire limiter)
  (process-request)

  ;; With timeout
  (acquire limiter :timeout 5.0)

  ;; Check available tokens
  (tokens-available limiter))

;; Using context macro
(with-rate-limit (limiter :tokens 1 :timeout 5.0)
  (make-api-call))

;; Handle rate limit exceeded
(with-rate-limit (limiter :on-exceeded (return :rate-limited))
  (process-request))
```

## API

- `make-rate-limiter` - Create token bucket limiter
- `try-acquire` - Non-blocking token acquisition
- `acquire` - Blocking token acquisition with optional timeout
- `release` - Return tokens to bucket
- `tokens-available` - Check current token count
- `refill-rate` - Get refill rate (tokens/second)
- `bucket-capacity` - Get maximum capacity
- `with-rate-limit` - Context macro for rate-limited operations

## License

BSD-3-Clause. Copyright (c) 2024-2026 Parkian Company LLC.
