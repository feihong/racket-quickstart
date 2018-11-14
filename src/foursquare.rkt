;; FourSquare API venue search
;; https://developer.foursquare.com/docs/api/venues/search
;; Category IDs: https://developer.foursquare.com/docs/resources/categories

#lang racket

(require threading)
(require net/url)
(require json)
(require "config.rkt")

(define (get-url . params)
  (let ([query-lst (~> (apply hash params) hash->list)])
    (~> (string->url "https://api.foursquare.com/v2/venues/search")
        (struct-copy url _ [query query-lst]))))

;; Main

(match-define
  (hash-table
    ("client-id" client-id) ("client-secret" client-secret))
  foursquare)

;;; (println client-id)
;;; (println client-secret)

(~> (get-url
      'client_id client-id
      'client_secret client-secret
      'll "41.967985,-87.688307"
      'intent "browse"
      'radius "1600"
      'categoryId "4d4b7105d754a06374d81259")
    (call/input-url get-pure-port read-json))  ; Food

