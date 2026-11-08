#!/bin/bash
set -xe

# The Makefile's ?= defaults are bypassed under conda-build (CXXFLAGS and
# CPPFLAGS are already present in the environment), so re-add the library
# include path and the C++20 standard here explicitly.
export CPPFLAGS="${CPPFLAGS} -I${PWD}/lib"
export CXXFLAGS="${CXXFLAGS} -std=c++20"

# std::format's floating-point formatter needs std::to_chars, which libc++
# only makes available from macOS 13.4; conda-forge targets macOS 10.13 by
# default.  Appended last so it overrides the -mmacosx-version-min that
# conda-build injects into CPPFLAGS.
if [ "$(uname -s)" = "Darwin" ]; then
  export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=13.4"
fi

mkdir -p "${PREFIX}/bin"

# Default 32-bit positional variant.  The conda-forge compiler activation
# exports BUILD (the build-platform triplet, e.g. x86_64-conda-linux-gnu),
# which collides with the Makefile's BUILD output directory, so pin it here.
make -C cli BUILD=build -j "${CPU_COUNT}"
cp cli/build/nabla "${PREFIX}/bin/nabla"

# 64-bit positional variant for inputs beyond 2^32 positions.
make -C cli LENGTH_SIZE=64 BUILD=build64 -j "${CPU_COUNT}"
cp cli/build64/nabla64 "${PREFIX}/bin/nabla64"
