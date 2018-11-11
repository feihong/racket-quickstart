#lang racket

(require racket/pretty)
(require net/http-client)

(define hc (http-conn-open "www.voachinese.com" #:ssl? #t))

(define-values (status headers port) (http-conn-sendrecv! hc "/"))

(printf "~a\n" status)
(pretty-print headers)

(define output (port->string port))
(printf "Response size: ~a\n" (string-length output))



(http-conn-close! hc)
