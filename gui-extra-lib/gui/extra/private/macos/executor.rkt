#lang racket/base

(provide
 executor)

(define executor (make-will-executor))
(thread
 (lambda ()
   (let loop ()
     (with-handlers ([exn:fail? (λ (e) ((error-display-handler) (exn-message e) e))])
       (will-execute executor))
     (loop))))
