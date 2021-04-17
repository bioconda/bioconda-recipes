#!/bin/bash

make -j"${CPU_COUNT}"
make install
if [ ${SHLIB_EXT} == ".dylib" ]; then
	mkdir -p ${PREFIX}/bin/lib
	cp -a ${PREFIX}/lib/liblrez* ${PREFIX}/bin/lib/
	cp -a ${PREFIX}/lib/liblrez* ${PREFIX}/bin/
fi
