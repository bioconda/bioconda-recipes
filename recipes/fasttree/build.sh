#!/bin/bash
set -ex

mkdir -p "${PREFIX}/bin"

case $(uname -m) in
    aarch64)
	export EXTRA_ARGS=""
		;;
    arm64)
	export EXTRA_ARGS=""
		;;
    x86_64)
	export EXTRA_ARGS="-fopenmp-simd -march=native"
		;;
esac

# build FastTree
${CC} -I${PREFIX}/include -L${PREFIX}/lib ${EXTRA_ARGS} -O3 -funsafe-math-optimizations -o FastTree FastTree.c -lm
install -v -m 0755 FastTree "${PREFIX}/bin"

# some OS are not case-sensitive (macOS, by default), ignore the copy error there
cp -f -- $PREFIX/bin/FastTree $PREFIX/bin/fasttree || True

# Build FastTreeMP
${CC} -I${PREFIX}/include -L${PREFIX}/lib ${EXTRA_ARGS} -DOPENMP -O3 -fopenmp -funsafe-math-optimizations -o FastTreeMP FastTree.c -lm
install -v -m 0755 FastTreeMP "${PREFIX}/bin"
