#!/bin/bash
set -ex

mkdir -p "${PREFIX}/bin"

case $(uname -m) in
    aarch64)
	export EXTRA_ARGS="-march=armv8-a"
		;;
    arm64)
	export EXTRA_ARGS="-march=armv8.4-a"
		;;
    x86_64)
	export EXTRA_ARGS="-fopenmp-simd -march=x86-64"
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

# https://github.com/bioconda/bioconda-recipes/pull/60340#issuecomment-3560431036
if [[ "$(uname -s)" == "Darwin" ]]; then
	install_name_tool -add_rpath "${PREFIX}/lib" "${PREFIX}/bin/FastTreeMP"
fi
