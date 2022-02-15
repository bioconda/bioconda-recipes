#!/bin/sh

./configure --prefix=${PREFIX} CXXFLAGS="${CXXFLAGS} -Wno-error=unused-result"
make install

mkdir -p ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/Examples
mkdir -p ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src
cp Examples/arcs-make ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/Examples
cp src/long-to-linked-pe ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src
cp Examples/makeTSVfile.py ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/Examples

echo "#!/bin/bash" > ${PREFIX}/bin/arcs-make
echo "make -f $(command -v ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/Examples/arcs-make) \$@" >> ${PREFIX}/bin/arcs-make
