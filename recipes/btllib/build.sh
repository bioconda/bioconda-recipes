#!/bin/bash

./compile

mkdir -p ${PREFIX}/bin/
mkdir -p ${PREFIX}/include/
mkdir -p ${PREFIX}/lib/

cp bin/* ${PREFIX}/bin/
cp include/* ${PREFIX}/include/
cp lib/libbtllib.a ${PREFIX}/lib/libbtllib.a

# python wrappers:

#!/bin/bash

cd src
make install
cd ..

mkdir -p ${PREFIX}/bin/
mkdir -p ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin
mkdir -p ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/physlr
#mkdir -p ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src

cp bin/physlr* ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/
cp physlr/*py ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/physlr/

cp src/physlr-indexlr ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src/physlr-indexlr
cp src/physlr-makebf ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src/physlr-makebf
cp src/physlr-filter-bxmx ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src/physlr-indexlr
cp src/physlr-filter-barcodes ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src/physlr-barcodes
cp src/physlr-molecules ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src/physlr-molecules
cp src/physlr-overlap ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src/physlr-overlap
cp src/physlr-split-minimizers ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src/physlr-split-minimizers

echo "#!/bin/bash" > ${PREFIX}/bin/physlr-make
echo "make -f $(command -v ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/physlr-make) \$@" >> ${PREFIX}/bin/physlr-make 