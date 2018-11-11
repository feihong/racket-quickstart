#lang racket

(call-with-output-file "test.txt" #:exists 'truncate
  (lambda (out)
    (for ([i (in-range 1 11)])
      (fprintf out "~a. 你好世界\n" i))))

(printf "Contents of file:\n~a\n" (file->string "test.txt"))
