#!/bin/bash
set -eux -o pipefail

make -C src

mkdir -p ${PREFIX}/bin/
mkdir -p ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin
mkdir -p ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src

cp src/long-to-linked-pe ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src
cp bin/* ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin
cp bin/tigmint* ${PREFIX}/bin/


echo "#!/bin/bash" > ${PREFIX}/bin/tigmint-make
echo "make -f $(command -v ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/tigmint-make) \$@" >> ${PREFIX}/bin/tigmint-make
