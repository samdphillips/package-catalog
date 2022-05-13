# package-catalog
Preview Racket Package Catalog of my packages.

https://samdphillips.github.io/package-catalog/

Based on https://github.com/samdphillips/pkg-catalog-demo .

Basic setup:
```
raco pkg config --set catalogs \
    https://samdphillips.github.io/package-catalog/catalog/ \
    https://download.racket-lang.org/releases/$YOUR_RACKET_VERSION/catalog/   \
    https://pkgs.racket-lang.org \
    https://planet-compats.racket-lang.org
```
