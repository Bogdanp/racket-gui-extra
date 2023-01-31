#lang racket/gui

(require racket/gui/extra)

(define f
  (new frame% [label "Text Field"]))
(new text-field%
     [parent f]
     [init-value "example"]
     [callback (λ (self event)
                 (printf "self: ~s event: ~s~n" self event))])
(send f show #t)
