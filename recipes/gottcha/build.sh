#!/bin/bash

mkdir -p $PREFIX/bin

cd $SRC_DIR/

./INSTALL.sh

cd bin/

cp *.pl $PREFIX/bin
cp splitrim $PREFIX/bin


