#lang racket/base

(require racket/class
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
          [init-value ""]
          [callback void])
    (init-rest)
    (public*
     [get-value
      (entry-point
       (lambda ()
         (send (mred:mred->wx this) get-value)))]
     [set-value
      (entry-point
       (lambda (v)
         (unless (string? v)
           (raise-argument-error 'set-value "string?" v))
         (send (mred:mred->wx this) set-value v)))])
    (call-as-atomic
     (lambda ()
       (super-instantiate
        [(lambda ()
           (make-object wx-text-field% this this
                        (mred:mred->wx-container parent)
                        init-value callback))
         (lambda ()
           (void))
         #f parent callback #f])))))

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
