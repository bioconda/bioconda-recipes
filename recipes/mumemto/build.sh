#!/bin/bash

set -xe

mkdir build
cd build
cmake ..
make -j"${CPU_COUNT}" install
cd ..

mkdir -p $PREFIX/bin
mkdir -p $SP_DIR/mumemto
mkdir -p $PREFIX/share/licenses/$PKG_NAME

cp build/mumemto_exec $PREFIX/bin/
cp build/newscanNT.x $PREFIX/bin/
cp mumemto/*.py $SP_DIR/mumemto/
cp mumemto/mumemto $PREFIX/bin/
cp LICENSE $PREFIX/share/licenses/$PKG_NAME/
chmod +x $PREFIX/bin/mumemto
touch $SP_DIR/mumemto/__init__.py 
