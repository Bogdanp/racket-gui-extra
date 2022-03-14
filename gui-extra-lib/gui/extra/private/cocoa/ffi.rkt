#lang racket/base

(require ffi/unsafe
         ffi/unsafe/atomic
         ffi/unsafe/nsalloc
         ffi/unsafe/nsstring
         ffi/unsafe/objc
         mred/private/lock
         mred/private/wx/cocoa/types
         (only-in mred/private/wx/cocoa/utils
                  as-objc-allocation
                  as-objc-allocation-with-retain
                  ->wxb ->wx))

(provide
 (all-from-out ffi/unsafe
               ffi/unsafe/atomic
               ffi/unsafe/nsalloc
               ffi/unsafe/nsstring
               ffi/unsafe/objc
               mred/private/lock
               mred/private/wx/cocoa/types)
 as-objc-allocation
 as-objc-allocation-with-retain
 ->wxb ->wx
 (all-defined-out))

(define _CGFloat
  (make-ctype
   _double
   (λ (v)
     (if (and (number? v)
              (exact?  v))
         (exact->inexact v)
         v))
   #f))

(define-cstruct _NSPoint ([x _CGFloat] [y _CGFloat]))
(define-cstruct _NSSize ([width _CGFloat] [height _CGFloat]))
(define-cstruct _NSRect ([origin _NSPoint] [size _NSSize]))
