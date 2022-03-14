#lang racket/gui

(require racket/gui/extra)

(define ds
  (new
   (class outline-view-datasource%
     (super-new)
     (define/override (get-item-child-count it)
       (cond
         [(not it) 1]
         [else 0]))

     (define/override (get-item-child it idx)
       (cond
         [(not it) "/"]
         [else #f]))

     (define/override (is-item-expandable? it)
       (equal? it "/")))))

(define f (new frame% [label "Outline"]))
(define o (new outline-view%
               [parent f]
               [callback void]
               [datasource ds]))
(send f show #t)
