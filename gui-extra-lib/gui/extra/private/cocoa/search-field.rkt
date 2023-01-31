#lang racket/base

(require racket/class
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

    (define (make-wx)
      (new wx-search-field%
           [mred this]
           [proxy this]
           [parent (mred:mred->wx-container parent)]
           [init-value init-value]
           [callback callback]))

    (with-atomic
      (super-instantiate
       (make-wx no-mismatches #f parent callback #f)))

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

(define ns-search-field%
  (text-field-mixin
   (class mred:item%
     (init parent init-value)
     (inherit-field callback)
     (field [value init-value])
     (super-new
      [parent parent]
      [cocoa (let ([cocoa (as-objc-allocation
                           (tell (tell RacketNSSearchField alloc) init))])
               (begin0 cocoa
                 (tellv cocoa setDelegate: cocoa)
                 (tellv cocoa setStringValue: #:type _NSString init-value)
                 (tellv cocoa sizeToFit)))])

     (define/public (search-did-start)
       (callback this 'begin-search))

     (define/public (search-did-end)
       (callback this 'end-search)))))

(define wx-search-field%
  (class (mred:make-window-glue% (mred:make-control% ns-search-field% 2 2 #t #f))
    (init mred proxy parent init-value callback)
    (super-make-object mred proxy null parent init-value callback)))
