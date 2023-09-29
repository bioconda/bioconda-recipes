#!/bin/bash
set -eu -o pipefail

mkdir -p ${PREFIX}/bin/
mkdir -p ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin

cp ntJoin ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
cp bin/*py ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin
cp bin/*py ${PREFIX}/bin

echo "#!/bin/bash" > ${PREFIX}/bin/ntJoin
echo "make -f $(command -v ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/ntJoin) \$@" >> ${PREFIX}/bin/ntJoin
