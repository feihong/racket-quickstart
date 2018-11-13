;; Get all hanzi from front page of VOA Chinese, then print out the most common
;; and the least common characters.
#lang racket

(require racket/generator)
(require threading)
(require net/url)

(define six-hours (* 6 60 60))

(define (file-is-recent? filename)
  (let ([diff (- (current-seconds) (file-or-directory-modify-seconds filename))])
    (< diff six-hours)))

(define (request-text)
  (~> "http://voachinese.com"
      string->url
      (get-pure-port/headers #:redirections 5 #:status? #t)))

(define (download-text)
  (let-values ([(port headers) (request-text)])
    (printf "Headers: ~a\n" (string-replace headers "\r\n" "\n"))
    (define text (port->string port))
    (printf "Response size: ~a\n" (string-length text))
    text))

(define (get-text)
  (let ([filename "voachinese.html"])
    (if (and (file-exists? filename) (file-is-recent? filename))
      (file->string filename)
      (let ([text (download-text)])
        (call-with-output-file filename #:exists 'truncate
          (lambda (out)
            (display text out)))
        text))))

(define (is-hanzi? c)
  (let ([ord (char->integer c)])
    (and (>= ord #x4e00) (<= ord #x9fff))))

;; Get the first n elements of the given list along with 1-based index
(define (take-with-number n lst)
  (in-generator
    (for ([i (in-range 1 (add1 n))]
          [x lst])
      (yield (cons i x)))))

;; Main

(define text (get-text))

;; Compute association list of hanzi and frequency count
(define counts-lst
  (let ([update-count (lambda (acc ch)
                          (hash-update acc ch
                            (lambda (n) (add1 n))   ; key already exists
                            (lambda () 0)))])       ; key doesn't exist
    (~>> (sequence-filter is-hanzi? text)
         (sequence-fold update-count (make-immutable-hash))
         hash->list
         (sort _ > #:key cdr))))

(printf "Found ~s total hanzi!\n\n" (length counts-lst))

(printf "Most common hanzi:\n")
(for ([item (take-with-number 20 counts-lst)])
  (match-let ([(cons i (cons k v)) item])
    (printf "~a. ~a => ~a\n" i k v)))

;; Compute list of hanzi that only appear once
(define once-hanzi
  (~>> counts-lst
       (sequence-filter (match-lambda [(cons k v) (= v 1)]))
       (sequence-map (lambda~>> car (make-string 1)))
       sequence->list))

(when (length once-hanzi)
  (printf "\nHanzi that only appear once (~a):\n" (length once-hanzi))
  (printf "~a\n" (string-join once-hanzi ", ")))
