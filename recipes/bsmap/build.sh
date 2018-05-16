#!/bin/bash

export CPATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I$PREFIX/include"

make

cp *.py ${PREFIX}/bin/
cp *.sh ${PREFIX}/bin/
cp bsmap ${PREFIX}/bin/

chmod +x ${PREFIX}/bin/*
