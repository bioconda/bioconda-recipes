#!/bin/bash

set -e -x -o pipefail

binaries="\
extract_fullseq \
"

mkdir -p $PREFIX/bin
#for i in $binaries; do cp $SRC_DIR/bmtagger/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done

if [ "$(uname)" == "Darwin" ]; then
    echo "Platform: Mac"

    for i in $binaries; do cp $SRC_DIR/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"

    make -j ${CPU_COUNT} -C general  CC="${CC}" CXX="${CXX}" DEBUG="${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++03"
    make -j ${CPU_COUNT} -C bmtagger CC="${CC}" CXX="${CXX}" DEBUG="${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++03"
    
    for i in $binaries; do cp $SRC_DIR/bmtagger/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done
fi

chmod +x $PREFIX/bin/*