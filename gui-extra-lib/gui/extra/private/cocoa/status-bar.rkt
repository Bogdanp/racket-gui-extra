#lang racket/base

(require (only-in mred/private/wx/common/event control-event%)
         (prefix-in base: racket/base)
         racket/class
         racket/list
         "common.rkt"
         "ffi.rkt"
         (prefix-in mred: "mred.rkt"))

(provide
 status-bar-menu%)

(import-class NSMenu NSMenuItem NSStatusBar)

(define status-bar-menu%
  (class* mred:mred% (mred:internal-menu<%> mred:wx<%>)
    (init-field image)
    (super-make-object this)

    (define-values (_cocoa cocoa-menu)
      (with-atomic
        (define status-bar
          (tell NSStatusBar systemStatusBar))
        (define-values (width _height)
          (send image get-size))
        (define cocoa
          (as-objc-allocation-with-retain
           (tell status-bar statusItemWithLength: #:type _CGFloat width)))
        (tell (tell cocoa button) setImage: (send image get-cocoa))
        (define cocoa-menu
          (as-objc-allocation
           (tell (tell NSMenu alloc)
                 initWithTitle: #:type _NSString "menu")))
        (tellv cocoa-menu setAutoenablesItems: #:type _BOOL #f)
        (tellv cocoa setMenu: cocoa-menu)
        (values cocoa cocoa-menu)))

    ;; mred ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (define/public (get-mred) this)
    (define/public (get-proxy) this)
    (define/public (get-container) this)

    ;; container ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (define items null)
    (define (push! item-wx)
      (set! items (base:append items (list item-wx))))
    (define (index-of-item item-wx)
      (for/first ([it (in-list items)]
                  [idx (in-naturals)]
                  #:when (and it (eq? it item-wx)))
        idx))
    (define (update item-wx proc)
      (define idx
        (index-of-item item-wx))
      (when idx
        (proc idx (tell cocoa-menu itemAtIndex: #:type _NSInteger idx))))

    (define/public (append-item _item _item-wx)
      (void))

    (define/public (append-separator)
      (set! items (base:append items (list #f)))
      (tellv cocoa-menu addItem: (tell NSMenuItem separatorItem)))

    (define/public (append item-wx label maybe-submenu checkable?)
      (send item-wx set-label label)
      (when (is-a? maybe-submenu mred:wx-menu%)
        (send item-wx set-submenu maybe-submenu)
        (send maybe-submenu set-parent this))
      (push! item-wx)
      (send item-wx set-parent this)
      (send item-wx install cocoa-menu checkable?))

    (define/public (delete item-wx _item)
      (update item-wx (λ (idx _cocoa-item)
                        (tellv cocoa-menu removeItemAtIndex: #:type _NSInteger idx)
                        (set! items (base:append (take items idx)
                                                 (drop items (add1 idx)))))))

    (define/public (enable item-wx _item on?)
      (update item-wx (λ (_idx cocoa-item)
                        (tellv cocoa-item setEnabled: #:type _BOOL on?)
                        (send item-wx set-enabled-flag (and on? #t)))))

    (define/public (check item-wx on?)
      (update item-wx (λ (_idx cocoa-item)
                        (tellv cocoa-item setState: #:type _NSInteger (if on? 1 0))
                        (send item-wx set-checked (and on? #t)))))

    (define/public (set-label item-wx label)
      (update item-wx (λ (_idx cocoa-item)
                        (define clean-label
                          (regexp-replace #rx"&(.)" label "\\1"))
                        (tellv cocoa-item setTitle: #:type _NSString clean-label)
                        (send item-wx set-label clean-label))))

    ;; FIXME: Need keymap support.  Called before `set-label`.
    (define/public (swap-item-keymap _item-wx _label)
      (void))

    ;; HACK: Act as if we are the top-level window in order to support
    ;; submenus.
    (define/public (get-top-window) this)
    (define/public (get-eventspace)
      (mred:current-eventspace))
    (define/public (on-menu-command item-wx)
      (item-command item-wx))

    ;; callbacks ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (define/public (item-selected item-wx)
      (mred:queue-callback
       (λ () (item-command item-wx))))

    (define/private (item-command item-wx)
      (define item (mred:wx->mred item-wx))
      (send item command (make-object control-event% 'menu)))))
