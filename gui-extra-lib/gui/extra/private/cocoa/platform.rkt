#lang racket/base

;; Must be loaded separately and before everything else.
(require "init.rkt")

(require (for-syntax racket/base)

         "image.rkt"
         "outline-view.rkt"
         "search-field.rkt"
         "status-bar.rkt"
         "text-field.rkt")

(provide
 platform-map)

(define platform-map
  (make-hasheq))

(define-syntax-rule (define-for-platform name ...)
  (begin (hash-set! platform-map 'name name) ...))

(define-for-platform
  ;; image.rkt
  image<%>
  image-view%
  make-image-from-symbol

  ;; outline-view.rkt
  outline-view-datasource%
  outline-view%

  ;; search-field.rkt
  search-field%

  ;; status-bar.rkt
  status-bar-menu%

  ;; text-field.rkt
  text-field%
  )
