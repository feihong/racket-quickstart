#lang racket

(require threading)

(printf "你好世界!\n\n")

(define (random-hanzi)
  (~> (random #x4e00 (add1 #x9fff))
      (integer->char)))

(printf "Totally random hanzi:\n")

(for ((_ 8))
  (printf "~c\n" (random-hanzi)))
