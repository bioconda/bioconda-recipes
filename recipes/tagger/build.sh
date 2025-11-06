#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/lib"

make CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 755 tagcorpus tagger_swig.py "${PREFIX}/bin"
install -v -m 755 libtagger.a libtagger.so _tagger_swig.so "${PREFIX}/lib"
