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

"Problem 3"

;; make-num-calls-table

"Problem 4"

;; memoize

"Problem 5 (optional)"

;; advise

"Problem 6 (optional)"

;; make-monitored-with-advice


;; Allow this file to be included from elsewhere, and export all defined
;; functions from it.
(provide (all-defined-out))
