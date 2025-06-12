#!/bin/sh

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
cp -r ${SRC_DIR} $PREFIX/lib/referee
sed -i 's#/usr/bin/python#/usr/bin/env python#g' $PREFIX/lib/referee/referee.py
ln -s $PREFIX/lib/referee/referee.py $PREFIX/bin/referee.py
