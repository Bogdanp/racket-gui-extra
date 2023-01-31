#lang racket/base

(require racket/class
         "common.rkt"
         "ffi.rkt"
         "mixin.rkt"
         (prefix-in mred: "mred.rkt"))

(provide
 text-field%)

(import-class NSTextField)

(define-objc-class RacketNSTextField NSTextField
  #:mixins (TextEditingDelegate)
  [wxb])

(define text-field%
  (class mred:basic-control%
    (init parent
          [label #f]
          [init-value ""]
          [callback void])
    (init-rest)

    (define (make-wx)
      (new wx-text-field%
           [mred this]
           [proxy this]
           [parent (mred:mred->wx-container parent)]
           [init-value init-value]
           [callback callback]))

    (with-atomic
      (super-instantiate
       (make-wx no-mismatches label parent callback #f)))

    (define/public (get-value)
      (with-entry-point
        (send (mred:mred->wx this) get-value)))

    (define/public (set-value v)
      (unless (string? v)
        (raise-argument-error 'set-value "string?" v))
      (with-entry-point
        (send (mred:mred->wx this) set-value v)))

    (define/public (select-all)
      (with-entry-point
        (send (mred:mred->wx this) select-all)))))

(define ns-text-field%
  (text-field-mixin
   (class mred:item%
     (init parent init-value callback)
     (field [value init-value])
     (super-new
      [parent parent]
      [callback callback]
      [cocoa (let ([cocoa (as-objc-allocation
                           (tell (tell RacketNSTextField alloc) init))])
               (begin0 cocoa
                 (tell cocoa setDelegate: cocoa)
                 (tell cocoa setStringValue: #:type _NSString init-value)
                 (tell cocoa sizeToFit)))]))))

(define wx-text-field%
  (class (mred:make-window-glue% (mred:make-control% ns-text-field% 2 2 #t #f))
    (init mred proxy parent init-value callback)
    (super-make-object mred proxy null parent init-value callback)))
