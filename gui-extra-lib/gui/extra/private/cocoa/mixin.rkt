#lang racket/base

(require racket/class
         "common.rkt"
         "ffi.rkt")


;; text-field<%> ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide
 TextEditingDelegate
 text-field<%>
 text-field-mixin)

(define-objc-mixin (TextEditingDelegate _Super)
  [wxb]
  [-a _void (controlTextDidBeginEditing: [_id notification])
      (try-send wxb text-did-begin-editing)]

  [-a _void (controlTextDidChange: [_id notification])
      (try-send wxb text-did-change (tell #:type _NSString self stringValue))]

  [-a _void (controlTextDidEndEditing: [_id notification])
      (try-send wxb text-did-end-editing)])

(define text-field<%>
  (interface ()
    text-did-begin-editing
    text-did-change
    text-did-end-editing))

(define (text-field-mixin %)
  (class* % (text-field<%>)
    (inherit-field callback value)
    (inherit get-cocoa)
    (super-new)

    (define/public (get-value) value)
    (define/public (set-value v)
      (set! value v)
      (tellv (get-cocoa) setStringValue: #:type _NSString v))

    (define/public (text-did-begin-editing)
      (callback this 'begin))

    (define/public (text-did-change text)
      (set! value text)
      (callback this 'text))

    (define/public (text-did-end-editing)
      (callback this 'commit))))
