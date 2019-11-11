#!/bin/bash

VER=$PKG_VERSION
mkdir -p $PREFIX/bin

curl -L https://github.com/mhoopmann/mstoolkit/archive/c936e547715a7537dfbdb12612d49cb15560bd98.tar.gz -o {VER}-src.tar.gz

tar xzf {VER}-src.tar.gz
mv mstoolkit-c936e547715a7537dfbdb12612d49cb15560bd98 ../MSToolkit

cd ../MSToolkit
sed -i.bak 's/-static//' Makefile
make CC=${CXX} GCC=${CC}
cd $SRC_DIR

sed -i.bak 's/-static//' Makefile

make CC=${CXX}
cp hardklor $PREFIX/bin
