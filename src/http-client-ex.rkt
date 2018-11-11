#lang racket

(require racket/pretty)
(require net/http-client)

(define (download-text)
  (define hc (http-conn-open "www.voachinese.com" #:ssl? #t))
  (define-values (status headers port) (http-conn-sendrecv! hc "/"))

  (printf "Status: ~a\n" status)
  (printf "Headers: ~a\n" (pretty-format headers))

  (define output (port->string port))
  (http-conn-close! hc)

  (printf "Response size: ~a\n" (string-length output))
  output)

(download-text)
