#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-register"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-register"

VER=$PKG_VERSION
mkdir -p "$PREFIX/bin"
mkdir -p ${PREFIX}/lib

curl -L https://github.com/mhoopmann/mstoolkit/archive/7c91d9ed03065f633a6de81e484a1be7d0e42db0.tar.gz -o {VER}-src.tar.gz

tar xzf {VER}-src.tar.gz
mv mstoolkit-7* ../MSToolkit

cd ../MSToolkit

sed -i.bak 's/-static//' Makefile
sed -i.bak 's/-O3/-O3 -Wno-register/' Makefile
rm -f *.bak

make CC="${CXX}" GCC="${CC}"

cp -f libmstoolkitlite.s* ${PREFIX}/lib
cd $SRC_DIR

sed -i.bak 's/-static//' Makefile
rm -f *.bak
if [[ "$target_platform" == "linux-aarch64" ]]; then
    sed -i.bak 's/complex/my_complex/g' FFT.h
    sed -i.bak 's/complex/my_complex/g' CMercury8.cpp
    sed -i.bak 's/complex/my_complex/g' CMercury8.h
    sed -i.bak 's/complex/my_complex/g' FFT-HK.cpp
    sed -i.bak 's/complex/my_complex/g' FFT.cpp
fi
make CC="${CXX}"

install -v -m 0755 hardklor "$PREFIX/bin"
