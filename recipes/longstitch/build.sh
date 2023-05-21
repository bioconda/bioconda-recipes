#!/bin/bash
mkdir -p ${PREFIX}/bin

mkdir -p ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/
cp longstitch ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/

echo "#!/bin/bash" > ${PREFIX}/bin/longstitch
echo "make -f $(command -v ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/longstitch) \$@" >> ${PREFIX}/bin/longstitch