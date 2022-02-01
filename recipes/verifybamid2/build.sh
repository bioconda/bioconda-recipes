#!/bin/bash
set -eu -o pipefail

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

# Avoid htslib test, which require /usr/bin/perl
sed -i.bak 's/ && make test//' CMakeLists.txt
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make
cd ..

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

mv bin/VerifyBamID $TGT/VerifyBamID
mkdir -p $TGT/resource $TGT/resource/exome
mv resource/1000g* $TGT/resource
mv resource/hgdp* $TGT/resource
mv resource/exome/1000g* $TGT/resource/exome
cp $RECIPE_DIR/verifybamid2.sh $TGT/verifybamid2
chmod a+x $TGT/verifybamid2
ln -s $TGT/verifybamid2 $PREFIX/bin/verifybamid2
