#!/bin/bash
set -ex

cd "${SRC_DIR}"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -fopenmp"
export CXXFLAGS="${CXXFLAGS} -fopenmp"

mkdir -p "${PREFIX}/bin"

"${CXX}" -std=c++11 \
  ${CXXFLAGS} \
  -I. -Iinclude -Iexternal \
  src/main.cpp \
  src/read_files.cpp \
  src/slct_loop.cpp \
  src/score.cpp \
  src/options.cpp \
  src/macojo.cpp \
  src/geno.cpp \
  ${LDFLAGS} \
  -o manc_cojo

install -m 0755 manc_cojo "${PREFIX}/bin/manc_cojo"
