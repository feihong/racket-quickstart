#lang racket

(require threading)
(require net/url)

(define (download-text)
  (define-values (port headers)
  (~> "http://voachinese.com"
      string->url
      (get-pure-port/headers #:redirections 5 #:status? #t)))

  (printf "Headers: ~a\n" (string-replace headers "\r\n" "\n"))

  (define text (port->string port))
  (printf "Response size: ~a\n" (string-length text))
  text)

(define (get-text)
  (define filename "voachinese.html")

  (if (file-exists? filename)
    (file->string filename)
    (begin
      (let ([text (download-text)])
        (call-with-output-file filename #:exists 'truncate
          (lambda (out)
            (display text out)))
        text))))

(get-text)
