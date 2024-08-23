#!/bin/bash

set -xe

mkdir -p "$PREFIX/bin"
export MACHTYPE=$(uname -m)
export BINDIR=$(pwd)/bin
export L="${LDFLAGS}"
mkdir -p "$BINDIR"
(cd kent/src/lib && make -j ${CPU_COUNT})
(cd kent/src/htslib && make -j ${CPU_COUNT})
(cd kent/src/jkOwnLib && make -j ${CPU_COUNT})
(cd kent/src/hg/lib && USE_HIC=0 make -j ${CPU_COUNT})
(cd kent/src/utils/bigBedToBed && make -j ${CPU_COUNT})
cp bin/bigBedToBed "$PREFIX/bin"
chmod +x "$PREFIX/bin/bigBedToBed"
