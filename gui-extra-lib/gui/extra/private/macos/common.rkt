#lang racket/base

(require racket/class
         "ffi.rkt")

(provide
 try-send*
 try-send)

(define-syntax-rule (try-send* who [what e ...] ...)
  (let ([wx (->wx who)])
    (when wx
      (send wx what e ...) ...)))

(define-syntax-rule (try-send who what e ...)
  (try-send* who [what e ...]))
