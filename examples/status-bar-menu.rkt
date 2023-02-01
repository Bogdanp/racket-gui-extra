#lang racket/base

(require racket/class
         (prefix-in gui: racket/gui)
         racket/gui/extra)

(define quit-sema
  (make-semaphore))

(define menu
  (new status-bar-menu%
       [image (make-image-from-symbol #:point-size 16 'ipad)]))

(new gui:menu-item%
     [parent menu]
     [label "Example 1"]
     [callback (λ (_self _event)
                 (displayln "Example 1 Clicked"))])

(define item2
  (new gui:menu-item%
       [parent menu]
       [label "Example 2"]
       [callback (λ (_self _event)
                   (displayln "Example 2 Clicked"))]))
(send item2 enable #f)

(new gui:menu-item%
     [parent menu]
     [label "Remove Me"]
     [callback (λ (self _event)
                 (send self delete))])

(new gui:separator-menu-item%
     [parent menu])

(new gui:checkable-menu-item%
     [parent menu]
     [label "Check Me"]
     [checked #t]
     [callback void])

(define submenu
  (new gui:menu%
       [parent menu]
       [label "Submenu"]))

(new gui:menu-item%
     [parent submenu]
     [label "Item 1"]
     [callback void])

(new gui:menu-item%
     [parent submenu]
     [label "Item 2"]
     [callback (λ (_self _event)
                 (displayln "Submenu item 2 clicked"))])

(new gui:menu-item%
     [parent menu]
     [label "Shout"]
     [callback (λ (self _event)
                 (send self set-label (string-append (send self get-label) "!")))])

(new gui:separator-menu-item%
     [parent menu])

(new gui:menu-item%
     [parent menu]
     [label "Quit"]
     [callback (λ (_self _event)
                 (semaphore-post quit-sema))])

(gui:yield quit-sema)
