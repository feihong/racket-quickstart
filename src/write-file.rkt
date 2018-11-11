#lang racket

(call-with-output-file "test.txt" #:exists 'truncate
  (lambda (out)
    (display "hello world\n你好世界" out)))

(printf "Contents of file: ~s\n" (file->string "test.txt"))
