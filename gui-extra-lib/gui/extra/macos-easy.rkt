#lang racket/base

(require racket/class
         racket/gui/easy
         (prefix-in gui: "macos.rkt"))

(provide
 input)

(define input%
  (class* object% (view<%>)
    (init-field @value action)
    (super-new)

    (define value (if (obs? @value) (obs-peek @value) @value))

    (define/public (dependencies)
      (filter obs? (list @value)))

    (define/public (create parent)
      (new gui:text-field%
           [parent parent]
           [callback (λ (self event)
                       (action event (send self get-value)))]
           [init-value value]))

    (define/public (update v who val)
      (case/dep who
        [@value
         (unless (equal? v val)
           (set! value val)
           (send v set-value val))]))

    (define/public (destroy _v)
      (void))))

(define (input @value [action void])
  (new input%
       [@value @value]
       [action action]))
