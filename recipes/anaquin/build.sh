#!/bin/bash
set -eu -o pipefail

# download and copy required dependencies
# klib
wget https://github.com/attractivechaos/klib/archive/spawn-final.tar.gz
tar xzf spawn-final.tar.gz
cp -r $SRC_DIR/klib-spawn-final $PREFIX/lib/klib/

# vcflib
wget https://github.com/student-t/vcflib-forAnaquin/archive/v1.0.0-rc1.tar.gz
tar xzf v1.0.0-rc1.tar.gz
cp -r $SRC_DIR/vcflib-forAnaquin-1.0.0-rc1/src $PREFIX/lib/vcflib/

# clean Makefile
sed -i'' -e 's/^BOOST.*//g' Makefile
sed -i'' -e 's/^EIGEN.*//g' Makefile
sed -i'' -e 's/^KLIB.*//g' Makefile
sed -i'' -e 's/^VCFLIB.*//g' Makefile
sed -i'' -e 's/\/include//g' Makefile
sed -i'' -e 's/-DBACKWARD_HAS_BFD//g' Makefile
sed -i'' -e 's/^INCLUDE.*//g' Makefile

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

export INCLUDE="$SRC_DIR/src"
export BOOST="$PREFIX/include/boost"
export EIGEN="$PREFIX/include/eigen3"
export KLIB="$PREFIX/lib"
export VCFLIB="$PREFIX/lib"

make
mkdir -p $PREFIX/bin
cp anaquin $PREFIX/bin

