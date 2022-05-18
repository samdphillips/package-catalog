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

I use [manage-catalog.rkt](https://github.com/samdphillips/package-catalog/blob/main/manage-catalog.rkt) 
to manage the package files.  It requires [`raco-run`](https://pkgs.racket-lang.org/package/raco-run) 
and [`threading`](https://pkgs.racket-lang.org/package/threading) to be installed.

```
Add Packages
./manage-catalog.rkt add-packages pkg-name1 url1 pkg-name2 url2 ...

Refresh Package Hashes
./manage-catalog.rkt refresh-packages catalog/pkg/*

Rebuild catalog/pkgs and catalog/pkgs-all
./manage-catalog.rkt build-catalog
```
