#!/bin/bash
set -euo pipefail

# The project defines no install() rule; install the binary explicitly.
mkdir -p "${PREFIX}/bin"

# vardictcpp builds a single C++17 binary with CMake and links conda's htslib.
# -DHTSLIB_ROOT points CMake at the host prefix (include/htslib + lib/libhts).
# The default build is portable (no -march=native), as Bioconda requires; the
# conda-injected CXXFLAGS land in CMAKE_CXX_FLAGS and are preserved. CMake picks
# up the conda C++ compiler from the CXX environment variable.
cmake -S . -B build \
	-DCMAKE_BUILD_TYPE=Release \
	-DHTSLIB_ROOT="${PREFIX}"

cmake --build build -j"${CPU_COUNT:-1}"
cmake --install build --prefix "$PREFIX"

#install -m 0755 build/vardictcpp "${PREFIX}/bin/vardictcpp"
