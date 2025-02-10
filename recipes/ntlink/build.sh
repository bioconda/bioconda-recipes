#!/bin/bash
set -eu -o pipefail

mkdir -p ${PREFIX}/bin/
mkdir -p ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin

cp ntLink* ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
cp bin/*py ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin

echo "#!/bin/bash" > ${PREFIX}/bin/ntLink
echo "make -f $(command -v ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/ntLink) \"\$@\"" >> ${PREFIX}/bin/ntLink
echo "#!/bin/bash" > ${PREFIX}/bin/ntLink_rounds
echo "make -f $(command -v ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/ntLink_rounds) \"\$@\"" >> ${PREFIX}/bin/ntLink_rounds
