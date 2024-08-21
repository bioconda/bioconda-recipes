#!/bin/bash

if [[ `uname` == "Darwin" ]]; then
	export CFLAGS="${CFLAGS} -O3 -Wno-register ${LDFLAGS} -L${PREFIX}/lib"
	export CXXFLAGS="${CXXFLAGS} -O3 -Wno-register -I${PREFIX}/include"
else
	export CFLAGS="${CFLAGS} -O3 ${LDFLAGS} -L${PREFIX}/lib"
        export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"
fi

sed -i.bak "s#\['cc',#\['${CC}',#" setup.py
rm -rf *.bak
${PYTHON} -m pip install --no-deps --no-build-isolation --no-cache-dir . -vvv
