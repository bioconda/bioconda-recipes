#!/bin/bash

export CPATH=${PREFIX}/include
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I$PREFIX/include"
export LIBRARY_PATH=${PREFIX}/lib

make

cp *.py ${PREFIX}/bin/
cp *.sh ${PREFIX}/bin/
cp bsmap ${PREFIX}/bin/

chmod +x ${PREFIX}/bin/*
