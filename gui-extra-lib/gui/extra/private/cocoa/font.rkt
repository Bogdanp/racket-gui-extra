#lang racket/base

(provide
 symbol->font-weight)

;; NSFontWeight
(define (symbol->font-weight s)
  (case s
    [(ultra-light) -0.8]
    [(thin) -0.6]
    [(light) -0.4]
    [(regular) 0]
    [(medium) 0.23]
    [(semibold) 0.3]
    [(bold) 0.4]
    [(heavy) 0.56]
    [(black) 0.62]
    [else (raise-argument-error 'symbol->font-weight "(or/c 'ultra-light 'thin 'light 'regular 'medium 'semibold 'bold 'heavy 'black)" s)]))
