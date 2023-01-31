#lang racket/base

(require racket/class
         "common.rkt"
         "ffi.rkt"
         (prefix-in mred: "mred.rkt"))

(provide
 outline-view-datasource%
 outline-view%)

(import-class NSNumber NSString NSObject NSOutlineView NSScrollView NSTableColumn)
(import-protocol NSOutlineViewDataSource)

(define-objc-class RacketNSOutlineView NSOutlineView
  [wxb])

(define-objc-class RacketNSOutlineViewDataSource NSObject
  #:protocols (NSOutlineViewDataSource)
  [wxb]
  [-a _id (outlineView: [_id _sender]
                        child: [_NSInteger index]
                        ofItem: [_id item])
    (with-unboxed-wx
      (define child-it
        (send wx get-item-child (and item (tell #:type _NSInteger item integerValue)) index))
      (tell NSNumber
            numberWithInteger:
            #:type _NSInteger child-it))]

  [-a _BOOL (outlineView: [_id _sender]
                          isItemExpandable: [_id item])
    (with-unboxed-wx
      (send wx is-item-expandable? (and item (tell #:type _NSInteger item integerValue))))]

  [-a _NSInteger (outlineView: [_id _sender]
                               numberOfChildrenOfItem: [_id item])
    (with-unboxed-wx
      (send wx get-item-child-count (and item (tell #:type _NSInteger item integerValue))))]

  [-a _id (outlineView: [_id _sender]
                        objectValueForTableColumn: [_id column]
                        byItem: [_id item])
    (with-unboxed-wx
      (define child
        (send wx get-item (and item (tell #:type _NSInteger item integerValue))))
      (define text
        (or child "???"))
      (tell (tell (tell NSString alloc) initWithUTF8String: #:type _string text) autorelease))])

(define outline-view-datasource-wrapper%
  (class object%
    (init-field ds)
    (super-new)

    (define seq 0)
    (define item-ids (make-hasheqv))

    ;; TODO: need box here
    (define (next-id!)
      (begin0 seq
        (set! seq (add1 seq))))

    (define (lookup-item it)
      (hash-ref item-ids it #f))

    (define (store-item! it)
      (cond
        [(hash-ref item-ids it #f)]
        [else
         (define id (next-id!))
         (begin0 id
           (hash-set! item-ids id it))]))

    (define/public (get-item it)
      (lookup-item it))

    (define/public (get-item-child it idx)
      (store-item!
       (send ds get-item-child (lookup-item it) idx)))

    (define/public (get-item-child-count it)
      (send ds get-item-child-count (lookup-item it)))

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
          [callback void]
          [columns '("Column")])
    (init-rest)

    (define (make-wx)
      (new wx-outline-view%
           [mred this]
           [proxy this]
           [parent (mred:mred->wx-container parent)]
           [datasource datasource]
           [callback callback]
           [columns columns]))

    (with-atomic
      (super-instantiate
       (make-wx no-mismatches #f parent callback #f)))))

(define ns-outline-view%
  (class mred:item%
    (init parent datasource columns)
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
    (for ([title (in-list columns)])
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
  (class (mred:make-window-glue% (mred:make-control% ns-outline-view% 0 0 #t #t))
    (init mred proxy parent datasource callback columns)
    (super-make-object mred proxy null parent datasource columns callback)))
