#!/bin/sh

cp -r ${SRC_DIR}/src/ $PREFIX/lib/monovar 
ln -s $PREFIX/lib/monovar/monovar.py $PREFIX/bin/monovar
