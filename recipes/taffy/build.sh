#!/bin/bash
set -ex

# Patch the Makefile to append 'PREFIX=.' to the abPOA make command
sed -i.bak 's|cd taffy/submodules/abPOA && ${MAKE}|& PREFIX=.|g' Makefile
# Patch the Makefile to link htslib for bgzip support
sed -i.bak 's|${LDLIBS}|${LDLIBS} -lhts|g' Makefile
rm -f Makefile.bak

export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CFLAGS="${CFLAGS} -DUSE_HTSLIB=1 -D_POSIX_C_SOURCE=200809L"
export CXXFLAGS="${CXXFLAGS} -DUSE_HTSLIB=1 -D_POSIX_C_SOURCE=200809L"

# Build and install the binary
make CC="${CC}" CXX="${CXX}" AR="${AR}"
mkdir -p ${PREFIX}/bin
install -v -m 755 bin/taffy ${PREFIX}/bin/

# Build and install the Python package bindings
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation --no-cache-dir