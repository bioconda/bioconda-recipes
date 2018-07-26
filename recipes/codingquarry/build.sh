#!/bin/sh

make
mkdir -p $PREFIX/bin
mv CodingQuarry $PREFIX/bin
cp -R $SRC_DIR/QuarryFiles ${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}/QuarryFiles

mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export QUARRYFILES=${PREFIX}/share/codingquarry/QuarryFiles" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh
