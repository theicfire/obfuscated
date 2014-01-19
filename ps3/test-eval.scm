
(define (test-equal? one two)
  (display (list one two))
  (if (equal? one two)
    (display 'pass)
    (display 'error))
  (newline))

(define (test)
  (test-equal? 4 (* 2 2))
  (test-equal? 5 (+ 3 2))
  (test-equal? 'a (cadr (list 'b 'a)))
  (test-equal? (list 'c) (cddr (list 'b 'a 'c)))
  (test-equal? 2 (length '(1 2)))
  (newline)
  (printf "new line above")
  )

(test)


