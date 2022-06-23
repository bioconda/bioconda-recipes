#!/bin/bash
set -eu

make -C src install

mkdir -p ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src

cp -a bin ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/
cp -a physlr ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/

cp src/physlr-indexlr src/physlr-makebf src/physlr-filter-bxmx src/physlr-filter-barcodes src/physlr-overlap src/physlr-split-minimizers ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src/

printf '#!/bin/bash\nexec make -f $(command -v '"${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/physlr-make"') "$@"' >${PREFIX}/bin/physlr
