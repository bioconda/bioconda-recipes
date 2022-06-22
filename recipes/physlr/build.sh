#!/bin/bash

make -C src install

mkdir -p ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src

cp -a bin ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/
cp -a physlr ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/

cp src/physlr-indexlr ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src/physlr-indexlr
cp src/physlr-makebf ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src/physlr-makebf
cp src/physlr-filter-bxmx ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src/physlr-indexlr
cp src/physlr-filter-barcodes ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src/physlr-barcodes
# cp src/physlr-molecules ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src/physlr-molecules
cp src/physlr-overlap ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src/physlr-overlap
cp src/physlr-split-minimizers ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src/physlr-split-minimizers

echo "#!/bin/bash" > ${PREFIX}/bin/physlr
echo "make -f $(command -v ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/physlr-make) \$@" >> ${PREFIX}/bin/physlr
