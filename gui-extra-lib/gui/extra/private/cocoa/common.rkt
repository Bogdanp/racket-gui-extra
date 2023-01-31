#lang racket/base

(require (for-syntax racket/base
                     racket/syntax
                     syntax/parse)
         (only-in mred/private/wx/common/queue queue-event)
         racket/class
         "ffi.rkt")

(provide
 with-atomic
 with-entry-point)

;; ffi ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-syntax-rule (with-atomic body0 body ...)
  (call-as-atomic
   (lambda ()
     body0 body ...)))

(define-syntax-rule (with-entry-point body0 body ...)
  (entry-point
   (lambda ()
     body0 body ...)))


;; wx ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide
 with-unboxed-wx
 try-send*
 try-send
 no-mismatches)

(define-syntax (with-unboxed-wx stx)
  (syntax-parse stx
    [(_ #:wxb-id wxb-id #:wx-id wx-id body ...+)
     #'(let ([wx-id (->wx wxb-id)])
         (and wx-id (let () body ...)))]
    [(_ body ...+)
     #:with wxb-id (format-id stx "wxb")
     #:with wx-id (format-id stx "wx")
     #'(with-unboxed-wx #:wxb-id wxb-id #:wx-id wx-id body ...)]))

(define-syntax-rule (try-send* who [what e ...] ...)
  (let ([wx (->wx who)])
    (when wx
      (queue-event
       (send wx get-eventspace)
       (λ ()
         (send wx what e ...) ...)))))

(define-syntax-rule (try-send who what e ...)
  (try-send* who [what e ...]))

(define (no-mismatches)
  null)
