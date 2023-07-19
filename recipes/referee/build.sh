#!/bin/sh

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
cp -r ${SRC_DIR} $PREFIX/lib/referee
ln -s $PREFIX/lib/referee/referee.py $PREFIX/bin/referee.py
