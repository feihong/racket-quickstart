;; Get all hanzi from front page of VOA Chinese, then print out the most common
;; and the least common characters.
#lang racket

(require threading)
(require net/url)

(define six-hours (* 6 60 60))

(define (file-is-recent? filename)
  (let ([diff (- (current-seconds) (file-or-directory-modify-seconds filename))])
    (< diff six-hours)))

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
    (if (and (file-exists? filename) (file-is-recent? filename))
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

(define once-hanzi
  (~>> counts-vec
       vector->list
       (filter (lambda (pair) (= (cdr pair) 1)))
       (map (lambda (pair) (~>> pair car (make-string 1))))))

(when (length once-hanzi)
  (printf "\nHanzi that only appear once (~a):\n" (length once-hanzi))
  (printf "~a\n" (string-join once-hanzi ", "))
)
