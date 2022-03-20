#!/usr/bin/env racket
#lang racket/base

(require racket/exn
         racket/file)

(define (load-pkg-file filename)
  (define (fail e)
    (log-error "error reading ~a~%~a" filename (exn->string e))
    #f)
  (with-handlers ([exn:fail? fail])
    (file->value filename)))

(module* main #f
  (define catalog-dir "catalog")

  (define packages
    (for/list ([filename (in-directory (build-path catalog-dir "pkg"))]
               #:when (file-exists? filename)
               [pkg-data (in-value (load-pkg-file filename))]
               #:when pkg-data)
      pkg-data))

  (write-to-file packages (build-path catalog-dir "pkgs-all"))
  (write-to-file (for/list ([pkg (in-list packages)])
                   (hash-ref pkg 'name))
                 (build-path catalog-dir "pkgs")))

