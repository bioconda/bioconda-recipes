#!/bin/bash
set -ex

# Build only the core percolator + qvality binaries.
#
# The XSD/Xerces-C based converters (sqt2pin, msgf2pin, tandem2pin) are
# intentionally not built. Upstream removed the XML/XSD code path from the core
# ("Remove XML/XSD support (incompatible with modern C++)",
# percolator/percolator#399) and the remaining converter XSD path does not
# compile against modern xerces-c. Skipping it keeps this package free of the
# xerces-c / xsd dependency. The core percolator/qvality tab-delimited
# (PIN/POUT) interface is unaffected.

cmake -S . -B percobuild \
    -DTARGET_ARCH="$(uname -m)" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCMAKE_PREFIX_PATH="$PREFIX;$PREFIX/lib" \
    -DCMAKE_CXX_COMPILER="$CXX"
cmake --build percobuild --target install -j"${CPU_COUNT}" -v

# Install the tab-delimited PIN test input used by the package test.
mkdir -p "$PREFIX/testdata"
cp -f "$SRC_DIR/data/percolator/tab/percolatorTab" "$PREFIX/testdata/percolatorTab"
