#lang racket/base

(require (only-in mred/private/wx/common/queue queue-event)
         racket/class
         "ffi.rkt")

(provide
 try-send*
 try-send)

(define-syntax-rule (try-send* who [what e ...] ...)
  (let ([wx (->wx who)])
    (when wx
      (queue-event
       (send wx get-eventspace)
       (λ ()
         (send wx what e ...) ...)))))

(define-syntax-rule (try-send who what e ...)
  (try-send* who [what e ...]))
