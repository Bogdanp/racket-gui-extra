#lang racket/gui

(require racket/gui/extra)

(define f (new frame% [label "iPad"]))
(define sv (new scroll-view% [parent f] [label #f]))
(send f show #t)
