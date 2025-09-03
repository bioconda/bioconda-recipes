#!/bin/bash
set -ex

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

case $(uname -m) in
    aarch64)
	export EXTRA_ARGS=""
	;;
    arm64)
	export EXTRA_ARGS=""
	;;
    x86_64)
	export EXTRA_ARGS="-fopen-simd -march=native"
	;;
esac

# build FastTree
${CC} ${EXTRA_ARGS} -O3 -funsafe-math-optimizations -o "$PREFIX/bin/FastTree" FastTree.c -lm
chmod +x $PREFIX/bin/FastTree

# some OS are not case-sensitive (macOS, by default), ignore the copy error there
cp -f -- $PREFIX/bin/FastTree $PREFIX/bin/fasttree || True

# Build FastTreeMP
${CC} ${EXTRA_ARGS} -DOPENMP -O3 -fopenmp -funsafe-math-optimizations -o "$PREFIX/bin/FastTreeMP" FastTree.c -lm
chmod +x $PREFIX/bin/FastTreeMP
