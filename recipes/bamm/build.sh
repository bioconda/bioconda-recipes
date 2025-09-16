#!/bin/bash

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* c/
cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* c/m4/

(rm -rf c/htslib-1.3.1/)
(cd c/ && ./autogen.sh)

find ${SRC_DIR} -name "*.py" -exec 2to3 -w -n {} \;
[[ -f "$SRC_DIR/bin/bamm" ]] && 2to3 -w -n ${SRC_DIR}/bin/bamm

${PYTHON} setup.py install --with-libhts-lib "${PREFIX}/lib" --with-libhts-inc "${PREFIX}/include/htslib"
