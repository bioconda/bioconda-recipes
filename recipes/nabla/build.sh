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

# Default 32-bit positional variant.  BUILD_DIR is set explicitly because
# rattler-build injects its own BUILD_DIR into the environment, which would
# otherwise override the Makefile's "build" default.
make -C cli BUILD_DIR=build -j "${CPU_COUNT}"
cp cli/build/nabla "${PREFIX}/bin/nabla"

# 64-bit positional variant for inputs beyond 2^32 positions.
make -C cli LENGTH_SIZE=64 BUILD_DIR=build64 -j "${CPU_COUNT}"
cp cli/build64/nabla64 "${PREFIX}/bin/nabla64"

# Install the manual page.
mkdir -p "${PREFIX}/share/man/man1"
cp man/nabla.1 "${PREFIX}/share/man/man1/nabla.1"
