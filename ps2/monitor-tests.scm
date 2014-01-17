#lang racket

(require r5rs)
(require rackunit)
(require "memoize.scm")




(test-case
 "Correctly redefined"
(define (fib n)
  (if (< n 2)
      n
      (+ (fib (- n 1)) (fib (- n 2)))))
  (check-equal? (fib 8) 21) ;; => 21
  (set! fib (make-monitored fib))
  (check-equal? (fib 8) 21) ;; => 21
  (check-equal? (fib 'how-many-calls?) 67) ;; => 67
  (check-equal? (fib 8) 21) ;; => 21
  (check-equal? (fib 'how-many-calls?) 134) ;; => 134
  (fib 'reset-count)
  (check-equal? (fib 'how-many-calls?) 0) ;; => 0
 )

(test-case
 "Incorrectly redefined"
  (define mon-fib (make-monitored fib))
  (mon-fib 8)
  (check-equal? (mon-fib 'how-many-calls?) 1)
 )

(display "Done running tests.")(newline)
