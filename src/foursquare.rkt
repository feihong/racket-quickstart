#lang racket

(require net/url)
(require "config.rkt")

(match-define
  (hash-table
    ("client-id" client-id) ("client-secret" client-secret))
  foursquare)

(println client-id)
(println client-secret)
