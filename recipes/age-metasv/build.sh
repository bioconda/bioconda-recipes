#!/bin/bash
mkdir -p $PREFIX/bin
make CXX="${CXX} ${CPPFLAGS} ${CXXFLAGS} -fopenmp -DOMP \$(DEFAULT_FLAGS) ${LDFLAGS}"
cp age_align $PREFIX/bin
