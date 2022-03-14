#lang racket/base

(require racket/class
         "ffi.rkt"
         (prefix-in mred: "mred.rkt"))

(provide
 outline-view-datasource%
 outline-view%)

(import-class NSCell NSNumber NSObject NSOutlineView NSScrollView NSTableColumn)
(import-protocol NSOutlineViewDataSource)

(define-objc-class RacketNSOutlineView NSOutlineView
  [wxb])

(define-objc-class RacketNSOutlineViewDataSource NSObject
  #:protocols (NSOutlineViewDataSource)
  [wxb]
  [-a _id (outlineView: [_id _sender]
                        child: [_NSInteger index]
                        ofItem: [_id item])
      (cond
        [(->wx wxb) => (λ (wx)
                         (define child-it
                           (send wx get-item-child (and item (tell #:type _NSInteger item integerValue)) index))
                         (tell NSNumber
                               numberWithInteger:
                               #:type _NSInteger child-it))]
        [else #f])]

  [-a _BOOL (outlineView: [_id _sender]
                          isItemExpandable: [_id item])
      (cond
        [(->wx wxb) => (λ (wx)
                         (printf "expandable?~n")
                         (send wx is-item-expandable? (and item (tell #:type _NSInteger item integerValue))))]
        [else #f])]

  [-a _NSInteger (outlineView: [_id _sender]
                               numberOfChildrenOfItem: [_id item])
      (cond
        [(->wx wxb) => (λ (wx)
                         (send wx get-item-child-count (and item (tell #:type _NSInteger item integerValue))))]
        [else 0])]

  [-a _id (outlineView: [_id _sender]
                        objectValueForTableColumn: [_id column]
                        byItem: [_id item])
      (cond
        [(->wx wxb) => (λ (wx)
                         (tell (tell (tell NSCell alloc) initTextCell: #:type _NSString "???") autorelease))]
        [else #f])])

(define outline-view-datasource-wrapper%
  (class object%
    (init-field ds)
    (super-new)

    (define seq 0)
    (define items (make-hasheqv))
    (define item-ids (make-weak-hasheq))

    ;; TODO: need box here
    (define (next-id!)
      (begin0 seq
        (set! seq (add1 seq))))

    (define (lookup-item it)
      (define maybe-item-id (hash-ref item-ids it #f))
      (define maybe-item-box (and maybe-item-id (hash-ref items maybe-item-id #f)))
      (and maybe-item-box (weak-box-value maybe-item-box)))

    (define (store-item! it)
      (cond
        [(hash-ref item-ids it #f)]
        [else
         (define id (next-id!))
         (begin0 id
           (hash-set! item-ids it id)
           (hash-set! items id (make-weak-box it)))]))

    (define/public (get-item-child it idx)
      (store-item!
       (send ds get-item-child (and it (lookup-item it)) idx)))

    (define/public (get-item-child-count it)
      (cond
        [(not it)
         (send ds get-item-child-count #f)]

        [(lookup-item it)
         => (λ (ds-it)
              (send ds get-item-child-count ds-it))]

        [else 0]))

    (define/public (is-item-expandable? it)
      (send ds is-item-expandable? (lookup-item it)))))

(define outline-view-datasource%
  (class object%
    (super-new)

    (define/public (get-item-child it idx)
      #f)

    (define/public (get-item-child-count it)
      0)

    (define/public (is-item-expandable? it)
      #f)))

(define outline-view%
  (class mred:basic-control%
    (init parent
          [datasource (new outline-view-datasource%)]
          [callback void])
    (init-rest)
    (call-as-atomic
     (lambda ()
       (super-instantiate
        [(lambda ()
           (make-object wx-outline-view% this this
                        (mred:mred->wx-container parent)
                        datasource callback))
         (lambda ()
           (void))
         #f parent datasource callback #f])))))

(define ns-outline-view%
  (class mred:item%
    (init parent datasource)
    (inherit-field callback)
    (inherit set-size)

    (define wrapped-ds
      (new outline-view-datasource-wrapper% [ds datasource]))
    (define ds
      (as-objc-allocation
       (tell (tell RacketNSOutlineViewDataSource alloc) init)))
    (set-ivar! ds wxb (->wxb wrapped-ds))

    (define cocoa
      (as-objc-allocation
       (tell (tell NSScrollView alloc) init)))
    (define content-cocoa
      (as-objc-allocation
       (tell (tell RacketNSOutlineView alloc) init)))
    (set-ivar! content-cocoa wxb (->wxb this))
    (tellv content-cocoa setDelegate: content-cocoa)
    (tellv content-cocoa setDataSource: ds)
    (for ([title '("Untitled")])
      (define col
        (as-objc-allocation
         (tell (tell NSTableColumn alloc) initWithIdentifier: #:type _NSString title)))
      (tellv content-cocoa addTableColumn: col)
      (tellv (tell col headerCell) setStringValue: #:type _NSString title))
    (tellv content-cocoa setStyle: #:type _NSInteger 1)
    (tellv cocoa setDocumentView: content-cocoa)
    (tellv cocoa setHasVerticalScroller: #:type _BOOL #t)
    (tellv cocoa setHasHorizontalScroller: #:type _BOOL #t)

    (define/override (get-cocoa-content) content-cocoa)
    (define/override (get-cocoa-control) content-cocoa)

    (super-new
     [parent parent]
     [cocoa cocoa])

    (set-size 0 0 32 50)))

(define wx-outline-view%
  (class (mred:make-window-glue% (mred:make-control% ns-outline-view% 2 2 #t #f))
    (init mred proxy parent datasource callback)
    (super-make-object mred proxy null parent datasource callback)))
