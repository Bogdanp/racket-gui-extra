#lang racket/base

(require racket/class
         "common.rkt"
         "ffi.rkt"
         "font.rkt"
         (prefix-in mred: "mred.rkt"))

(provide
 image<%>
 make-image-from-symbol)

(import-class NSImage NSImageSymbolConfiguration)

(define image<%>
  (interface ()
    get-cocoa
    get-size))

(define image%
  (class* object% (image<%>)
    (init-field cocoa)
    (field
     [width (NSSize-width (tell #:type _NSSize cocoa size))]
     [height (NSSize-height (tell #:type _NSSize cocoa size))])
    (super-new)

    (define/public (get-cocoa) cocoa)
    (define/public (get-size)
      (values width height))))

(define (make-image-from-symbol name
                                [description #f]
                                #:point-size [point-size #f]
                                #:weight [weight #f])
  (define name-str
    (symbol->string name))
  (define cocoa
    (with-atomic
      (let ([cocoa (as-objc-allocation-with-retain
                    (tell NSImage
                          imageWithSystemSymbolName: #:type _NSString name-str
                          accessibilityDescription: #:type _NSString (or description name-str)))])
        (when (or point-size weight)
          (define cocoa-config
            (tell NSImageSymbolConfiguration
                  configurationWithPointSize: #:type _CGFloat (or point-size 12)
                  weight: #:type _CGFloat (if weight (symbol->font-weight weight) 0)))
          (as-objc-allocation-with-retain
           (tell cocoa imageWithSymbolConfiguration: cocoa-config))))))
  (new image% [cocoa cocoa]))


;; image-view% ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide image-view%)

(import-class NSImageView)

(define NSImageScaleProportionallyDown 0)
(define NSImageScaleAxesIndependently 1)

(define-objc-class RacketNSImageView NSImageView
  [wxb])

(define image-view%
  (class mred:basic-control%
    (init parent image)
    (init-rest)

    (define (make-wx)
      (new wx-image-view%
           [mred this]
           [proxy this]
           [parent (mred:mred->wx-container parent)]
           [image image]))

    (with-atomic
      (super-instantiate
       (make-wx no-mismatches #f parent void #f)))))

(define ns-image-view%
  (class mred:item%
    (init parent image)
    (super-new
     [parent parent]
     [callback void]
     [cocoa (let ()
              (define cocoa
                (as-objc-allocation
                 (tell (tell RacketNSImageView alloc) init)))
              (define-values (w h)
                (send image get-size))
              (begin0 cocoa
                (tellv cocoa setImageScaling: #:type _long NSImageScaleAxesIndependently)
                (tellv cocoa setImage: (send image get-cocoa))
                (tellv cocoa setFrame: #:type _NSRect (make-NSRect
                                                       (make-NSPoint 0 0)
                                                       (make-NSSize w h)))))])))

(define wx-image-view%
  (class (mred:make-window-glue% (mred:make-control% ns-image-view% 0 0 #f #f))
    (init mred proxy parent image)
    (super-make-object mred proxy null parent image)))
