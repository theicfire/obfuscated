#lang racket


"Part 1: Numerical integration"

"Problem 1: Bitdiddle's function"

; (define (bitfunc x)
    ; (+ (- (expt x 4) (* 5 (expt x 2)))) 4)

(define (bitfunc x)
    (+ (- (expt x 4) (* 5 (expt x 2))) 4))

;; Some simple test cases, based on by-eye examination of a graph of the
;; function: https://www.google.com/search?q=x^4-5*x^2%2B4   Run these,
;; and check that they match with the expectations.
(bitfunc 0)  ;; Should be 4
(bitfunc 1)  ;; Should be 0, or very close
(bitfunc 2)  ;; Should also be very close to 0
(bitfunc -1) ;; Should also also be very close to 0
(bitfunc 3) ;; 40
(bitfunc 10) ;; large number


"Problem 2: A rectangle under Bitdiddle's function"

(define (bitfunc-rect x1 x2)
    (* (bitfunc x1) (- x2 x1)))

;; Test cases:
(bitfunc-rect 0 1)   ;; Should be 4
(bitfunc-rect 0 0.5) ;; Should be 2
(bitfunc-rect 1.5 2) ;; Should be negative
(+ (bitfunc-rect 3 4.5) (bitfunc-rect 4.5 6)) 
(bitfunc-rect 3 4) 
(bitfunc-rect 4 5) 
(bitfunc-rect 5 6) 
(+ (bitfunc-rect 3 4) (bitfunc-rect 4 5) (bitfunc-rect 5 6)) 

"Problem 3: Integrating Bitdiddle's function"

(define (bitfunc-integral-recur-wrap num-steps x1 x2)
  (bitfunc-integral-recur x1 num-steps (/ (- x2 x1) num-steps)))

(define (bitfunc-integral-recur start times incr)
  (if (= times 1)
    (bitfunc-rect start (+ start incr))
    (+
      (bitfunc-rect start (+ start incr))
      (bitfunc-integral-recur 
        (+ start incr) 
        (- times 1) 
        incr))))

(define (bitfunc-integral-iter num-steps x1 x2)
  (bitfunc-integral-iter2 num-steps x1 x2 0))

(define (bitfunc-integral-iter2 num-steps x1 x2 cur)
  (if (= num-steps 0)
    cur
    (bitfunc-integral-iter2
      (- num-steps 1) 
      (+ x1 (/ (- x2 x1) num-steps))
      x2
      (+ cur (bitfunc-rect x1 (+ x1 (/ (- x2 x1) num-steps)))))))

;; Provide your own test cases for this function.  Think about what are
;; the simplest input values to know are correct, and show that those
;; work as expected before moving on to test a couple more complicated
;; situations.
(* 1.0 (bitfunc-integral-recur-wrap 50 3 6)) ;approach 1200, this step is 1171
(* 1.0 (bitfunc-integral-iter 50 3 6)) ;approach 1200, this step is 1171


"Problem 4: Comparing the two integrators"

(define (bitfunc-integral-difference num-steps x1 x2)
  (abs (- (bitfunc-integral-iter num-steps x1 x2)
     (bitfunc-integral-recur-wrap num-steps x1 x2))))

;; Provide test cases for this one as well; only a couple should be
;; needed, as this function should be fairly straightforward.
(bitfunc-integral-difference 3 4 7)
(bitfunc-integral-difference 8 4 7)
