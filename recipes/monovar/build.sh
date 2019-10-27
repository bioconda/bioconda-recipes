#!/bin/sh

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib/monovar
cp -r ${SRC_DIR}/src/ $PREFIX/lib/monovar 
ln -s $PREFIX/lib/monovar/monovar.py $PREFIX/bin/monovar
