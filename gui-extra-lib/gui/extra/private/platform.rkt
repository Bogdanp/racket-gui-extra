#lang racket/base

(require (for-syntax racket/base
                     setup/cross-system)
         racket/runtime-path
         setup/cross-system)

(define-runtime-path platform-mod
  #:runtime?-id runtime?
  (case (if runtime? (system-type) (cross-system-type))
    [(macosx) '(lib "racket/gui/extra/private/cocoa/platform.rkt")]))

(define platform-map
  (dynamic-require platform-mod 'platform-map))

(define-syntax-rule (define-from-platform name ...)
  (begin
    (begin
      (define name (hash-ref platform-map 'name #f))
      (provide name)) ...))

(define-from-platform
  image<%>
  image-view%
  make-image-from-symbol

  outline-view-datasource%
  outline-view%

  search-field%

  status-bar-menu%

  text-field%)
