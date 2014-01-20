
(define (test-equal? one two)
  (display (list one two))
  (if (equal? one two)
    (display 'pass)
    (display 'fail))
  (newline))

(define (test)
  (test-equal? 4 (* 2 2))
  (define a 3)
  (test-equal? 5 (+ a 2))
  (test-equal? 'a (cadr (list 'b 'a)))
  (test-equal? (list 'c) (cddr (list 'b 'a 'c)))
  (test-equal? 2 (length '(1 2)))
  (test-equal? #f (and #f #t))

  ; Testing and
  (define a 3)
  (define (incr) 
      (display "run incr")
      (set! a (+ a 1))
      #t)
  (test-equal? #t (incr))
  (test-equal? 4 a)
  (test-equal? #f (and #f #f (incr)))
  (test-equal? 4 a)
  (test-equal? #t (and #t #t #t))
  (test-equal? #f (and #t #f))
  (test-equal? #f (and #t #t #f))


  ; Testing Until
  (define a 4)
  (define (incr2) 
      (set! a (+ a 1))
      #f)
  (until (> a 7)
    (incr2))
  (test-equal? 8 a)


  ; Testing procedure-env, env-value
  (define (make-counter)
    (let ((n 0))
      (lambda ()
        (set! n (+ n 1))
        n)))

  (define c (make-counter))
  (c)
  (c)
  (test-equal? 2 (env-value 'n (procedure-env c)))


  (define (fn2)
    (let ((a 0) (b 1))
      (lambda ()
        (set! n (+ n 1))
        n)))
  (define c (fn2))
  (test-equal? '(a b) (env-variables (procedure-env c)))
  ; (display (list
  ;   "next"
  ;   (env-variables (procedure-env c))))

  ; Printing tests
  (newline)
  (printf "new line above")
  )

(test)


