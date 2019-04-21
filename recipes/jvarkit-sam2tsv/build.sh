#!/bin/bash

OUT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p $OUT
mkdir -p $PREFIX/bin

cp -rvp . $PREFIX
cd $PREFIX
make sam2tsv
cp dist/*jar $OUT
cp dist/sam2tsv $OUT

ls -l $OUT
ln -s $OUT/sam2tsv $PREFIX/bin

chmod 0755 "${PREFIX}/bin/sam2tsv"
