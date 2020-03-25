#!/bin/bash

if [[ "${PY_VER}" =~ 3 ]]
then
	2to3 -w -n .
fi

mkdir -p bin
export CFLAGS="-I${PREFIX}/include -L${PREFIX}/lib -fpermissive"
make -j 2
cp bin/* ${PREFIX}/bin
chmod +x mapsplice.py
cp mapsplice.py ${PREFIX}/bin
