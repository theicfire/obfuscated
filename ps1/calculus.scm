#lang racket


"Part 1: Numerical integration"

"Problem 1: Integrating any function"


(define (bitf x)
    (+ (- (expt x 4) (* 5 (expt x 2))) 4))

(define (rect func x1 x2)
    (* (func x1) (- x2 x1)))

(define (integral func num-steps x1 x2)
  (integral-iter func num-steps x1 x2 0))

(define (integral-iter func num-steps x1 x2 cur)
  (if (= num-steps 0)
    cur
    (integral-iter
      func
      (- num-steps 1) 
      (+ x1 (/ (- x2 x1) num-steps))
      x2
      (+ cur (rect func x1 (+ x1 (/ (- x2 x1) num-steps)))))))

(* 1.0 (integral bitf 50 3 6)) ;approach 1200, this step is 1171

;; Test cases:

;; With only one step, the integral of y = x^2 from 3 to 5
;; should be 3^2 * 2 = 18
(integral (lambda (x) (expt x 2)) 1 3 5)
;; With two steps, we should get 3^2 + 4^2 = 25
(integral (lambda (x) (expt x 2)) 2 3 5)

"Problem 2: Area of a unit circle"

(define (approx-pi num-steps)
  (* 4 (integral (lambda (x) (sqrt (- 1 (* x x)))) num-steps 0 1)))
(approx-pi 1)   ;; Should be 4
(approx-pi 2)   ;; Hopefully lower than 4
(approx-pi 600) ;; Right to the first two decimal places?

"Problem 3: Integrating with pieces of any shape"

(define (rectangle func x1 x2)
    (* (func x1) (- x2 x1)))

(define (rectangle-right func x1 x2)
    (* (func x2) (- x2 x1)))

(define (trapezoid func x1 x2)
  (+ 
    (rectangle func x1 x2)
    (/ 
      (- (rectangle-right func x1 x2) (rectangle func x1 x2))
      2)))

; (define (integral-with piece func num-steps x1 x2)
;     'your-code-here)
(define (integral-with piece func num-steps x1 x2)
  (integral-with-iter piece func num-steps x1 x2 0))

(define (integral-with-iter piece func num-steps x1 x2 cur)
  (if (= num-steps 0)
    cur
    (integral-with-iter
      piece
      func
      (- num-steps 1) 
      (+ x1 (/ (- x2 x1) num-steps))
      x2
      (+ cur (piece func x1 (+ x1 (/ (- x2 x1) num-steps)))))))

;; Write your own test cases.  Start with checking that calling
;; (integral-with rectangle ...) is the same as calling (integral ...)
;; Then check that (integral-with trapezoid ...) produces better answers
;; for a given num-steps than the same (integral-with rectangle ...)
(* 1.0 (integral-with rectangle bitf 50 3 6)) ;approach 1200, this step is 1171
(* 1.0 (integral-with trapezoid bitf 50 3 6)) ;approach 1200, this step is 1171


"Problem 4: Better approximation of pi"

(define (better-pi num-steps)
  (* 4 (integral-with trapezoid (lambda (x) (sqrt (- 1 (* x x)))) num-steps 0 1)))
(better-pi 1)   ;; Should be 4
(better-pi 2)   ;; Hopefully lower than 4
(better-pi 600) ;; Right to the first two decimal places?

;; How many digits does (better-pi 600) get correct, compared to
;; the earlier (approx-pi 600) ?


"Part 2: Symbolic differentiation"

(define (deriv-constant constant wrt)
    0)


"Problem 5: Derivative of a variable"

(define (deriv-variable var wrt)
  (if (eq? var wrt) 1 0))

(deriv-variable 'x 'x)
(deriv-variable 'y 'x)


"Problem 6: Calling the right function"

(define (isadd? expr)
  (and (list? expr) (eq? '+ (car expr))))
(define (ismul? expr)
  (and (list? expr) (eq? '* (car expr))))
(define (derivative expr wrt)
    (cond
      ((number? expr) (deriv-constant expr wrt))
      ((symbol? expr) (deriv-variable expr wrt))
      ((isadd? expr)  (deriv-sum expr wrt))
      ((ismul? expr)  (deriv-product expr wrt))
        (else (error "Don't know how to differentiate" expr))))

(derivative 3 'x)
(derivative 'x 'x)
; (derivative * 'x) ; should create an error


"Problem 7: Derivative of a sum"


(define (deriv-sum expr wrt)
  (list '+ (derivative (cadr expr) wrt) (derivative (caddr expr) wrt)))

(derivative '(+ x 2) 'x)

"Problem 8: Derivative of a product"

(define (deriv-product expr wrt)
  (list '+
    (list '* 
      (cadr expr)
      (derivative (caddr expr) wrt))
    (list '*
      (caddr expr)
      (derivative (cadr expr) wrt))))

(derivative '(* x 3) 'x) ; 


"Problem 9: Additional testing"

; Additional test cases for 'derivative' go here.
(derivative '(* (+ x 1) 3) 'x) ; 3
