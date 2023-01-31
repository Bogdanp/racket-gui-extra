#lang racket/gui

(require racket/gui/extra)

(define ipad
  (make-image-from-symbol
   #:point-size 64
   #:weight 'ultra-light
   'ipad))

(define f (new frame% [label "iPads"]))
(define hp (new horizontal-panel% [parent f]))
(new image-view% [parent hp] [image ipad])
(new image-view% [parent hp] [image ipad])
(new image-view% [parent hp] [image ipad])
(new image-view% [parent hp] [image ipad])
(send f show #t)
