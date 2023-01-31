#lang racket/base

(require racket/class
         "common.rkt"
         "executor.rkt"
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
    (let ([cocoa (tell NSImage
                       imageWithSystemSymbolName: #:type _NSString name-str
                       accessibilityDescription: #:type _NSString (or description name-str))])
      (cond
        [(and (not point-size)
              (not weight))
         (tell cocoa retain)]

        [else
         (define cocoa-config
           (tell NSImageSymbolConfiguration
                 configurationWithPointSize: #:type _CGFloat (or point-size 12)
                 weight: #:type _CGFloat (if weight (symbol->font-weight weight) 0)))

         (tell (tell cocoa imageWithSymbolConfiguration: cocoa-config) retain)])))
  (define the-image
    (new image%
         [cocoa cocoa]))
  (begin0 the-image
    (will-register executor the-image (λ (_the-image)
                                        (tell cocoa release)))))


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
    (with-atomic
      (super-new
       [mk-wx (λ ()
                (new wx-image-view%
                     [mred this]
                     [proxy this]
                     [parent (mred:mred->wx-container parent)]
                     [image image]))]
       [mismatches (λ () null)]
       [parent parent]
       [cursor #f]
       [lbl #f]
       [cb void]))))

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
  (class (mred:make-window-glue% (mred:make-control% ns-image-view% 2 2 #f #f))
    (init mred proxy parent image)
    (super-make-object mred proxy null parent image)))
