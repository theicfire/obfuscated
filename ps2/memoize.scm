#lang racket

;; By default, Racket doesn't have set-car! and set-cdr! functions.  The
;; following line allows us to use those:
(require r5rs)
;; Unfortunately, it does this by making cons return a "mutable pair"
;; instead of a "pair", which means that many built-ins may fail
;; mysteriously because they expect a pair, but get a mutable pair.
;; Re-define a few common functions in terms of car and friends, which
;; the above line make work with mutable pairs.
(define first car)
(define rest cdr)
(define second cadr)
(define third caddr)
(define fourth cadddr)
;; We also tell DrRacket to print mutable pairs using the compact syntax
;; for ordinary pairs.
(print-as-expression #f)
(print-mpair-curly-braces #f)


"Problem 1"

(define (make-entry a b)
  (list 'entry a b))
(define (entry? entry)
  (and (pair? entry)
    (eq? (car entry) 'entry)))
(define (entry-key entry)
  (if (entry? entry)
    (cadr entry)
    (error "object not an entry" entry)))
(define (entry-val entry)
  (if (entry? entry)
    (caddr entry)
    (error "object not an entry" entry)))


(define (make-table)
  (list 'table))
(define (table? table)
  (and (pair? table)
    (eq? (car table) 'table)))
(define (table-first table)
  (if (table? table)
    (if (pair? (cdr table))
      (cadr table)
      (error "table is empty:" table))
    (error "table-first: object not a table:" table)))
(define (table-next table)
  (if (table? table)
    (if (pair? (cdr table))
      (cons 'table (cddr table))
      (error "table is empty:" table))
    (error "table-next object not a table:" table)))
(define (table-empty table)
  (if (table? table)
    (null? (cdr table))
    (error "table-empty object not a table:" table)))

(define (table-put! table key value)
  (if (table? table)
    (set-cdr! table (cons (make-entry key value) (cdr table)))
    (error "table-put! object not a table:" table)))

(define (table-has-key? table key)
  (if (table? table)
    (if (table-empty table)
      #f
      (if (equal? key (entry-key (table-first table)))
          #t
          (table-has-key? (table-next table) key)))
    (error "table-has-ke? object not a table:" table)))

(define (table-get table key)
  (if (table? table)
    (if (equal? key (entry-key (table-first table)))
        (entry-val (table-first table))
        (table-get (table-next table) key))
    (error "table-get object not a table:" table)))

"Problem 2"
(define (fib n)
  (if (< n 2)
      n
      (+ (fib (- n 1)) (fib (- n 2)))))

;; make-monitored
"check make monitored"
(define (make-monitored fn)
  (let ((count 0))
    (lambda (n)
      (cond 
        ((eq? n 'how-many-calls?) count)
        ((eq? n 'reset-count) (set! count 0))
        (else (begin
          (set! count (+ count 1))
          (fn n)))))))



"Problem 3"

;; make-num-calls-table
(define (make-num-calls-table fn max)
  (let ((table (make-table)))
    (define (rec current-it)
      (if (<= current-it max)
        (begin
          (fib 'reset-count)
          (fib current-it)
          (table-put! table current-it (fib 'how-many-calls?))
          (rec (+ current-it 1)))))
      ; do stuff
    (rec 1)
    table))

(set! fib (make-monitored fib))
(make-num-calls-table fib 30)
(fib 3)
(fib 'how-many-calls?)
; (entry 30 2692537)
; (entry 20 21891)

"Problem 4"

;; memoize
(define (memoize fn)
  (let ((table (make-table)))
    (lambda (n)
      (cond
        ((table-has-key? table n) (table-get table n))
        (else (let ((ans (fn n)))
                (table-put! table n ans)
                ans))))))

(set! fib (memoize fib))
(fib 'reset-count)
(fib 8)
(fib 'how-many-calls?)

"Problem 5 (optional)"

;; advise

"Problem 6 (optional)"

;; make-monitored-with-advice


;; Allow this file to be included from elsewhere, and export all defined
;; functions from it.
(provide (all-defined-out))
