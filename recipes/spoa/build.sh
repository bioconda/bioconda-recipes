#!/bin/bash
set -eoux pipefail

export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

cmake -S . -B build \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DBUILD_SHARED_LIBS=ON \
	-Dspoa_install=ON \
	-Dspoa_build_exe=ON \
	-Dspoa_optimize_for_portability=ON \
	-Dspoa_use_simde=ON \
	-Dspoa_use_simde_openmp=ON \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}"

cmake --build build/ --target install -j 4 -v
