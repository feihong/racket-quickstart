;; FourSquare API venue search
;; https://developer.foursquare.com/docs/api/venues/search
;; Category IDs: https://developer.foursquare.com/docs/resources/categories

#lang racket

(require racket/pretty)
(require net/url)
(require json)
(require threading)
(require mischief/json)
(require lens)
(require "config.rkt")

(define (get-url . params)
  (let ([query-lst (~> (apply hash params) hash->list)])
    (~> (string->url "https://api.foursquare.com/v2/venues/search")
        (struct-copy url _ [query query-lst]))))

(define (request-json)
  (match-let* (
    [(hash-table ("client-id" client-id) ("client-secret" client-secret))
     foursquare]
    [url (get-url
            'v "20181114"                           ; version based on date
            'categoryId "4d4b7105d754a06374d81259"  ; Food
            'client_id client-id
            'client_secret client-secret
            'll "41.967985,-87.688307"
            'intent "browse"
            'radius "1600")])
    (printf "Fetching from ~s\n" (url->string url))
    (call/input-url url get-pure-port read-json)))

(define (get-json)
  (let ([filename "foursquare.json"])
    (if (file-exists? filename)
      (call-with-input-file filename (lambda (in) (read-json in)))
      (let ([expr (request-json)])
        (call-with-output-file "foursquare.json" #:exists 'truncate
          (lambda (out) (stylish-write-json expr out)))
        expr))))

;; Main

(define expr (get-json))

(call-with-output-file "foursquare.rkt.txt" #:exists 'truncate
  (lambda (out)
    (pretty-print expr out)))

(define name-and-address
  (lens-join/hash 'name (hash-ref-lens 'name)
                  'address (hash-ref-nested-lens 'location 'address)))

(~>> (lens-view (hash-ref-nested-lens 'response 'venues) expr)
     (sequence-map (curry lens-view name-and-address))
     (sequence-for-each (curry printf "~a\n")))
