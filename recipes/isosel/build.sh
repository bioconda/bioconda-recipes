#!/bin/bash
set -exo pipefail

# The Makefiles append -fopenmp to CFLAGS/CXXFLAGS/LDFLAGS, so the flags are
# passed through the environment (not the make command line) to keep that.
export CFLAGS="${CFLAGS} -O3 -std=c11"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++11"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ "$(uname -s)" == "Darwin" ]]; then
	# Point the Makefiles at conda's llvm-openmp instead of Homebrew.
	export OMP_PREFIX="${PREFIX}"
	export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

make -C src/fastdist all CC="${CC}" -j"${CPU_COUNT}"
make -C src/fastdist install PREFIX="${PREFIX}"

make -C src/isosel all CXX="${CXX}" -j"${CPU_COUNT}"
make -C src/isosel install PREFIX="${PREFIX}"
