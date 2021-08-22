#lang racket/base

(require racket/class
         (prefix-in gui: racket/gui)
         racket/math
         "common.rkt"
         "ffi.rkt"
         "mixin.rkt"
         (prefix-in mred: "mred.rkt"))

(provide
 search-field%)

(import-class NSSearchField)

(define-objc-class RacketNSSearchField NSSearchField
  #:mixins (TextEditingDelegate)
  [wxb]
  [-a _void (searchFieldDidStartSearching: [_id sender])
      (try-send wxb search-did-start)]
  [-a _void (searchFieldDidEndSearching: [_id sender])
      (try-send wxb search-did-end)])

(define search-field%
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
           (make-object wx-search-field% this this
                        (mred:mred->wx-container parent)
                        init-value callback))
         (lambda ()
           (void))
         #f parent callback #f])))))

(define ns-search-field%
  (text-field-mixin
   (class mred:item%
     (init parent init-value)
     (inherit-field callback)
     (inherit get-cocoa)
     (field [value init-value])
     (super-new
      [parent parent]
      [cocoa (let ([cocoa (as-objc-allocation
                           (tell (tell RacketNSSearchField alloc) init))])
               (begin0 cocoa
                 (tell cocoa setDelegate: cocoa)
                 (tell cocoa setStringValue: #:type _NSString init-value)
                 (tell cocoa sizeToFit)))])

     (define/public (search-did-start)
       (callback this 'begin-search))

     (define/public (search-did-end)
       (callback this 'end-search)))))

(define wx-search-field%
  (class (mred:make-window-glue% (mred:make-control% ns-search-field% 2 2 #t #f))
    (init mred proxy parent init-value callback)
    (super-make-object mred proxy null parent init-value callback)))
