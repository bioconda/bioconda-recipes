#!/bin/bash
make CXX="${CXX}" \
  CXXFLAGS="${CXXFLAGS} -std=c++11 -DVERSION='\"${PKG_VERSION}\"' -DGIT_COMMIT='\"conda\"' -DGIT_DATE='\"${PKG_VERSION}\"'" \
  INCLUDES="-I./src -I${PREFIX}/include" \
  LIBS="-L${PREFIX}/lib -lz -lhts"
make install PREFIX="${PREFIX}"
