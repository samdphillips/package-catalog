#!/usr/bin/env -S PLTSTDOUT=info@catalog raco run
#lang racket/base

(require pkg/private/stage
         racket/exn
         racket/file
         racket/pretty
         racket/string
         threading)

(define-logger catalog)
(define catalog-dir "catalog")

(define (read-pkg-file filename)
  (define (fail e)
    (log-catalog-error "error reading ~a~%~a" filename (exn->string e))
    #f)
  (with-handlers ([exn:fail? fail])
    (file->value filename)))

(define (write-pkg-file pkg-hash filename)
  (with-output-to-file filename
    #:exists 'replace
    (lambda ()
      (pretty-write pkg-hash))))

(define (maybe-update-pkg-checksum pkg-hash)
  (define old-checksum
    (hash-ref pkg-hash 'checksum #f))
  (define new-checksum
    (package-url->checksum (hash-ref pkg-hash 'source)
                           #:download-printf
                           (lambda args
                             (log-catalog-info
                               (string-trim (apply format args))))))
  (cond
   [(equal? (hash-ref pkg-hash 'checksum #f) new-checksum) pkg-hash]
   [else
     (log-catalog-info "~a checksum changed, old: ~s, new: ~s"
                       (hash-ref pkg-hash 'name)
                       old-checksum
                       new-checksum)
     (hash-set pkg-hash 'checksum new-checksum)]))

(define (add-package name url)
  (~> (hash 'name name 'source url)
      maybe-update-pkg-checksum
      (write-pkg-file (build-path "catalog" "pkg" name))))

(module* add-packages #f
  (require racket/sequence)
  (for ([name+url (in-slice 2 (current-command-line-arguments))])
    (apply add-package name+url)))

(module* refresh-pkgs #f
  (for ([pkg-filename (in-vector (current-command-line-arguments))])
    (~> (read-pkg-file pkg-filename)
        maybe-update-pkg-checksum
        (write-pkg-file pkg-filename))))

(module* build-catalog #f
  (define packages
    (let* ([pkg-path (build-path catalog-dir "pkg")]
           [pkg-files (directory-list #:build? #t pkg-path)])
      (for/list ([filename (in-list pkg-files)]
                 #:when (file-exists? filename)
                 [pkg-data (in-value (read-pkg-file filename))]
                 #:when pkg-data)
        (log-catalog-info "found package ~a" (hash-ref pkg-data 'name #f))
        pkg-data)))

  (write-to-file #:exists 'replace
                 packages (build-path catalog-dir "pkgs-all"))
  (write-to-file #:exists 'replace
                 (for/list ([pkg (in-list packages)])
                   (hash-ref pkg 'name))
                 (build-path catalog-dir "pkgs")))

