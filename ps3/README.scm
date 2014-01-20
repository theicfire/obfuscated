; ===RUNNING INSTRUCTIONS===
  ; Tests:
    ; $ cat test-eval.scm | rlwrap racket -f eval.scm -i
  ; Metacircular:
    ; $ racket -f eval.scm -i
    ; > (load-meval-defs)
    ; > (driver-loop)
    ; > (driver-loop)

; ===QUESTION ANSWERS===
; ======QUESTION 1========
; Done in (define (primitive-procedures)
; Here's what I added:
; +        (list '* *)
; +        (list 'load load)
; +        (list '/ /)
; +        (list 'list list)
; +        (list 'cadr cadr)
; +        (list 'cddr cddr)
; +        (list 'newline newline)
; +        (list 'printf printf)
; +        (list 'length length)

; ======QUESTION 2========
; And is special because it should not evaluate any arguments following an argument that evaluates to false.
; Ex: (and #f (set! cheetah 6)) should not set cheetah to 6

; Git diff below:

;    (cons 'let (cons bindings body)))
 
;  (define (begin? exp) (tagged-list? exp 'begin))
; +(define (and? exp) (tagged-list? exp 'and))
; +(define (and-clauses exp) (cdr exp))
; +(define (make-and seq) (cons 'and seq))
;  (define (begin-actions begin-exp) (cdr begin-exp))
;  (define (last-exp? seq) (null? (cdr seq)))
;  (define (first-exp seq) (car seq))
; @@ -99,10 +102,13 @@
;  ;;
 
;  (define (m-eval exp env)
; +  ; (display (list "exp request" exp))
; +  ; (define exp 2)
;    (cond ((self-evaluating? exp) exp)
;          ((variable? exp) (lookup-variable-value exp env))
;          ((quoted? exp) (text-of-quotation exp))
;          ((assignment? exp) (eval-assignment exp env))
; +        ((and? exp) (m-eval (and->if exp) env))
;          ((definition? exp) (eval-definition exp env))
;          ((if? exp) (eval-if exp env))
;          ((lambda? exp)
; @@ -153,6 +159,17 @@
;                      (m-eval (definition-value exp) env)
;                      env))
 
; +(define (and->if exp)
; +  (let ((clauses (and-clauses exp)))
; +    (if (null? clauses)
; +      #t
; +      (make-if (first-cond-clause clauses)
; +        (make-and (rest-cond-clauses clauses))
; +        ; (begin
; +        ;   (display "and eval first")
; +        ;   #t)
; +        #f))))
; +
;  (define (let->application expr)
;    (let ((names (let-bound-variables expr))
;          (values (let-values expr))
; @@ -353,6 +370,7 @@
;          (list 'newline newline)
;          (list 'printf printf)
;          (list 'length length)
; +        (list 'equal? equal?)
;          ))




; ======QUESTION 3========
; Git diff below:

; +(define (until? exp) (tagged-list? exp 'until))
; +(define (until-test exp) (cadr exp))
; +(define (until-body exp) (cddr exp))
; +
;  (define (begin-actions begin-exp) (cdr begin-exp))
;  (define (last-exp? seq) (null? (cdr seq)))
;  (define (first-exp seq) (car seq))
; @@ -109,6 +113,7 @@
;          ((quoted? exp) (text-of-quotation exp))
;          ((assignment? exp) (eval-assignment exp env))
;          ((and? exp) (m-eval (and->if exp) env))
; +        ((until? exp) (m-eval (until->if exp) env))
;          ((definition? exp) (eval-definition exp env))
;          ((if? exp) (eval-if exp env))
;          ((lambda? exp)
; @@ -170,6 +175,22 @@
;          ;   #t)
;          #f))))
 
; +; from http://stackoverflow.com/questions/3172768/adding-an-element-to-list-in-scheme
; +(define (extend l . xs)
; +  (if (null? l) 
; +      xs
; +      (cons (car l) (apply extend (cdr l) xs))))
; +
; +(define (until->if exp)
; +  (make-let '()
; +    (list (make-begin (list
; +      (make-define '(loop)
; +        (make-if (until-test exp)
; +          #t
; +          (make-begin (extend (until-body exp) '(loop)))))
; +      '(loop))))))
; +
; +
; ======QUESTION 4========
; Git diff below:

;  (define (variable? exp) (symbol? exp))
;  (define (assignment? exp) (tagged-list? exp 'set!))
; +(define (unset? exp) (tagged-list? exp 'unset!))
;  (define (assignment-variable exp) (cadr exp))
;  (define (assignment-value exp) (caddr exp))
;  (define (make-assignment var expr)
; @@ -114,6 +115,7 @@
;          ((variable? exp) (lookup-variable-value exp env))
;          ((quoted? exp) (text-of-quotation exp))
;          ((assignment? exp) (eval-assignment exp env))
; +        ((unset? exp) (eval-unset exp env))
;          ((procedure-env? exp) (eval-procedure-env exp env))
;          ((and? exp) (m-eval (and->if exp) env))
;          ((until? exp) (m-eval (until->if exp) env))
; @@ -162,6 +164,10 @@
;                         (m-eval (assignment-value exp) env)
;                         env))
 
; +(define (eval-unset exp env)
; +  (unset-variable-value! (assignment-variable exp)
; +                       env))
; +
;  (define (eval-definition exp env)
;    (define-variable! (definition-variable exp)
;                      (m-eval (definition-value exp) env)
; @@ -361,10 +367,27 @@
;          (binding-value binding)
;          (error "Unbound variable -- LOOKUP" var))))
 
; +(define (add-binding-value! binding val)
; +  (if (binding? binding)
; +      (set-cdr! (cdr binding) (cons val (cddr binding)))
; +      (error "Not a binding: " binding)))
; +
; +(define (remove-binding-value! binding)
; +  (if (binding? binding)
; +      (if (<= 4 (length binding))
; +        (set-cdr! (cdr binding) (cdddr binding)))
; +      (error "Not a binding: " binding)))
; +
;  (define (set-variable-value! var val env)
;    (let ((binding (find-in-environment var env)))
;      (if binding
; -        (set-binding-value! binding val)
; +        (add-binding-value! binding val)
; +        (error "Unbound variable -- SET" var))))
; +
; +(define (unset-variable-value! var env)
; +  (let ((binding (find-in-environment var env)))
; +    (if binding
; +        (remove-binding-value! binding)
;          (error "Unbound variable -- SET" var))))
 
;  (define (define-variable! var val env)
; ======QUESTION 5========
; Long git diff below :)
; +(define (procedure-env? exp) (tagged-list? exp 'procedure-env))
; +(define (procedure-env-proc exp) (cadr exp))
 
;  (define (begin-actions begin-exp) (cdr begin-exp))
;  (define (last-exp? seq) (null? (cdr seq)))
; @@ -106,12 +108,13 @@
;  ;;
 
;  (define (m-eval exp env)
; -  ; (display (list "exp request" exp))
; -  ; (define exp 2)
; +  ; (display (list "REQUEST" exp))
; +  ; (newline)
;    (cond ((self-evaluating? exp) exp)
;          ((variable? exp) (lookup-variable-value exp env))
;          ((quoted? exp) (text-of-quotation exp))
;          ((assignment? exp) (eval-assignment exp env))
; +        ((procedure-env? exp) (eval-procedure-env exp env))
;          ((and? exp) (m-eval (and->if exp) env))
;          ((until? exp) (m-eval (until->if exp) env))
;          ((definition? exp) (eval-definition exp env))
; @@ -164,6 +167,12 @@
;                      (m-eval (definition-value exp) env)
;                      env))
 
; +(define (eval-procedure-env exp env)
; +  (procedure-environment
; +    (binding-value
; +      (find-in-environment (procedure-env-proc exp) env))))
; +; TODO current-env
; +
;  (define (and->if exp)
;    (let ((clauses (and-clauses exp)))
;      (if (null? clauses)
; @@ -260,6 +269,10 @@
;    (if (binding? binding)
;        (third binding)
;        (error "Not a binding: " binding)))
; +(define (binding-value-noerror binding)
; +  (if (binding? binding)
; +      (third binding)
; +      #f))
;  (define (set-binding-value! binding val)
;    (if (binding? binding)
;        (set-car! (cddr binding) val)
; @@ -363,6 +376,14 @@
;             (make-binding var val)
;             frame)))))
 
; +(define (env-value var env)
; +  (binding-value-noerror (find-in-environment var env)))
; +
; +(define (env-variables env)
; +  (frame-variables (environment-first-frame env)))
; +
; +(define (env-parent env)
; +  (enclosing-environment env))
;  ; primitives procedures - hooks to underlying Scheme procs
;  (define (make-primitive-procedure implementation)
;    (list 'primitive implementation))
; @@ -386,8 +407,14 @@
;          (list 'load load)
;          (list '/ /)
;          (list 'list list)
; +        (list 'list? list?)
; +        (list 'string-append string-append)
; +        (list 'make-string make-string)
;          (list 'cadr cadr)
;          (list 'cddr cddr)
; +        (list 'env-value env-value)
; +        (list 'env-variables env-variables)
; +        (list 'env-parent env-parent)


; ======QUESTION 6========
; Git diff below:
; 
;  (define (primitive-procedures)
;    (list (list 'car car)
;          (list 'cdr cdr)
; +        (list 'caddr caddr)
; +        (list 'caadr caadr)
; +        (list 'cdadr cdadr)
; +        (list 'cadddr cadddr)
; +        (list 'symbol? symbol?)
; +        (list 'pair? pair?)
; +        (list 'eq? eq?)
; +        (list 'number? number?)
; +        (list 'string? string?)
; +        (list 'boolean? boolean?)
;          (list 'cons cons)
;          (list 'set-car! set-car!)
;          (list 'set-cdr! set-cdr!)
; @@ -456,7 +466,7 @@
;          (list 'read-line        read-line)
;          (list 'open-input-file  open-input-file)
;          (list 'this-expression-file-name
; -                    (lambda () (this-expression-file-name)))
; +                    (lambda () "eval.scm"))

; =====TIMING======
; Timing: 0. 8. 732. Full output below.
; 
; (define (fib n)
;   (if (< n 2)
;       n
;       (+ (fib (- n 1)) (fib (- n 2)))))
; > (time (fib 8))
; cpu time: 0 real time: 1 gc time: 0
; 21
; > (load-meval-defs)
; loaded
; > (driver-loop)


; ;;; M-Eval input level 1
; (define (fib n)
;   (if (< n 2)
;       n
;       (+ (fib (- n 1)) (fib (- n 2)))))

; ;;; M-Eval value:
; #<void>


; ;;; M-Eval input level 1
; (time (fib 8))
; cpu time: 8 real time: 9 gc time: 0

; ;;; M-Eval value:
; 21


; ;;; M-Eval input level 1
; (driver-loop)


; ;;; M-Eval input level 2
; (define (fib n)
;   (if (< n 2)
;       n
;       (+ (fib (- n 1)) (fib (- n 2)))))

; ;;; M-Eval value:
; #<void>


; ;;; M-Eval input level 2
; (time (fib 8))
; cpu time: 732 real time: 733 gc time: 8

; ;;; M-Eval value:
; 21