#!/bin/sh

set -eux -o pipefail

./configure && make

mkdir -p ${PREFIX}/bin/
mkdir -p ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin
mkdir -p ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src

cp src/LINKS_CPP ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src
cp bin/* ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin
cp bin/LINKS* ${PREFIX}/bin/


echo "#!/bin/bash" > ${PREFIX}/bin/LINKS-make
echo "make -f $(command -v ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/LINKS-make) \$@" >> ${PREFIX}/bin/LINKS-make

######./configure --prefix=${PREFIX} CXXFLAGS="${CXXFLAGS} -Wno-error=unused-result"
######make install


##mkdir -p ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin
#mkdir -p ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src

##cp bin/LINKS ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin
##cp bin/LINKS-make ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin
#cp src/LINKS_CPP ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/src

##mkdir -p $PREFIX/bin
##mkdir -p $PREFIX/src
#####cp bin/LINKS $PREFIX/bin
#####cp bin/LINKS-make $PREFIX/bin
##cp src/LINKS_CPP $PREFIX/src

#chmod +x $PREFIX/bin/*

#echo "#!/bin/bash" > ${PREFIX}/bin/LINKS
#echo "make -f $(command -v ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/Examples/arcs-make) \$@" >> ${PREFIX}/bin/arcs-make

#####################################
