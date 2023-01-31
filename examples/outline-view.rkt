#lang racket/gui

(require racket/gui/extra)

;; NOTE: The outline view is not ready for use yet.  The code below
;; mostly works, but the implementation is incomplete and partially
;; wrong.

(define tree
  (hash
   "/" '("a" "b")
   "a" '()
   "b" '("c")
   "c" '()))

(define ds
  (new
   (class outline-view-datasource%
     (super-new)
     (define/override (get-item-child-count it)
       (length (hash-ref tree (or it "/") null)))

     (define/override (get-item-child it idx)
       (cond
         [(not it) "/"]
         [else (list-ref (hash-ref tree it) idx)]))

     (define/override (is-item-expandable? it)
       (not (null? (hash-ref tree (or it "/"))))))))

(define f (new frame%
               [label "Outline"]
               [width 600]
               [height 300]))
(define o (new outline-view%
               [parent f]
               [callback void]
               [datasource ds]))
(send f show #t)
