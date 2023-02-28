#!/bin/bash

# Do not use the included pre-compiled Boost.
rm -rf Src/*.a Src/boost

make -C Src/ CXX="${CXX}" CXXFLAGS="${CPPFLAGS} ${CXXFLAGS}" LIBS="${LDFLAGS}"

mv bin/rapsearch ${PREFIX}/bin/
mv bin/prerapsearch ${PREFIX}/bin/
