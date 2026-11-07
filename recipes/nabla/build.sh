#!/bin/bash
set -xe

# The Makefile's ?= defaults are bypassed under conda-build (CXXFLAGS and
# CPPFLAGS are already present in the environment), so re-add the library
# include path and the C++20 standard here explicitly.
export CPPFLAGS="${CPPFLAGS} -I${PWD}/lib"
export CXXFLAGS="${CXXFLAGS} -std=c++20"

mkdir -p "${PREFIX}/bin"
make -C cli -j "${CPU_COUNT}"
cp cli/build/nabla "${PREFIX}/bin/nabla"
