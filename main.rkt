#lang racket

(define current-dir (current-directory))
(init-database)

(require web-server/servlet
         web-server/servlet-env
         "backend.rkt"
         "frontend.rkt")

(exit-handler
 (λ (v)
   (close-database)
   (exit v)))

(serve/servlet start-servlet
               #:launch-browser? #f
               #:quit? #f
               #:listen-ip #f
               #:port 8000
               #:servlet-path "/"
               #:servlet-regexp #rx"")

