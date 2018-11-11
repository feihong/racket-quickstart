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
  (let ([filename "voachinese.html"])
    (if (file-exists? filename)
      (file->string filename)
      (begin
        (let ([text (download-text)])
          (call-with-output-file filename #:exists 'truncate
            (lambda (out)
              (display text out)))
          text)))))

(define (is-hanzi? c)
  (let ([ord (char->integer c)])
    (and (>= ord #x4e00) (<= ord #x9fff))))

;; Main

(define text (get-text))

(define counts-vec
  (let ([update-count (lambda (acc ch)
                          (hash-update acc ch
                            (lambda (n) (add1 n))
                            (lambda () 0)))])
    (~>> (for/list ([ch text] #:when (is-hanzi? ch)) ch)
         (sequence-fold update-count (make-immutable-hash))
         hash->list
         (sort _ > #:key cdr)
         list->vector)))

(printf "Found ~s total hanzi!\n\n" (vector-length counts-vec))

(printf "Most common hanzi:\n")
(for ([i 20])
  (match-let ([(cons k v) (vector-ref counts-vec i)])
    (printf "~a. ~a => ~a\n" (add1 i) k v)))
