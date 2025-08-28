#!/bin/bash
set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -I${PREFIX}/include/htslib"
export CXXFLAGS="${CXXFLAGS} -Wall -Wno-parentheses -pthread -std=c++14 -O3"

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/var/lib/arriba"

# compile Arriba
make CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	CXX="${CXX}" \
	bioconda -j"${CPU_COUNT}"

# install executables
install -v -m 0755 arriba run_arriba.sh draw_fusions.R scripts/* "${PREFIX}/bin"

# copy database files
cp -prf test/* database/* download_references.sh "${PREFIX}/var/lib/arriba/"
