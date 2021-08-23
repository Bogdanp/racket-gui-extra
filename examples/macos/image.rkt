#lang racket/gui

(require racket/gui/extra/macos)

(define ipad
  (make-image-from-symbol
   #:point-size 32
   'ipad))

(define f (new frame% [label "iPad"]))
(new image-view% [parent f] [image ipad])
(send f show #t)
