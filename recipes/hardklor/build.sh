#!/bin/bash

VER=$PKG_VERSION
mkdir -p $PREFIX/bin

curl -L https://github.com/mhoopmann/mstoolkit/archive/7c91d9ed03065f633a6de81e484a1be7d0e42db0.tar.gz -o {VER}-src.tar.gz

tar xzf {VER}-src.tar.gz
mv mstoolkit-7* ../MSToolkit

cd ../MSToolkit
sed -i.bak 's/-static//' Makefile
make CC=${CXX} GCC=${CC}
cd $SRC_DIR

sed -i.bak 's/-static//' Makefile

make CC=${CXX}
cp hardklor $PREFIX/bin
