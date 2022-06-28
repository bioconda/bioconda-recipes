#!/bin/bash
set -eu

make -C src install

mkdir -p ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src
mkdir -p ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/data


cp -a bin ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/
cp -a physlr ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/

cp src/physlr-indexlr src/physlr-makebf src/physlr-filter-bxmx src/physlr-filter-barcodes src/physlr-overlap src/physlr-split-minimizers ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src/
cp data/plotbed.rmd data/plot-depth.rmd data/plothistogram.rmd data/plotpaf.rmd data/quast.rmd data/plot-degree.rmd data/plot-edge-n.rmd data/plot-mxperbx.rmd data/profile-physlr.Rmd ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/data/

printf '#!/bin/bash\nexec make -f $(command -v '"${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/physlr-make"') "$@"' >${PREFIX}/bin/physlr
