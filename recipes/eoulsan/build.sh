#! /bin/bash


DIR=$(basename $SRC_DIR)

cp -r $SRC_DIR $PREFIX
chmod 755 $PREFIX/$DIR/eoulsan.sh

mkdir -p $PREFIX/bin
ln -s $PREFIX/$DIR/eoulsan.sh $PREFIX/bin
