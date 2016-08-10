#!/bin/sh
set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib "
export CPPFLAGS="-I${PREFIX}/include -I${PREFIX}/include/ncursesw/"
export CFLAGS="$CPPFLAGS"

export CFLAGS_EXTRA="${LDFLAGS} ${CPPFLAGS}"

find -name Makefile | xargs -I {} sed -i.bak 's/-lcurses/-lncurses/g' {}

make

mkdir -p $PREFIX/bin

cp -rf ref-eval/ref-eval $PREFIX/bin/
cp -rf ref-eval/ref-eval-estimate-true-assembly $PREFIX/bin/

cp -rf rsem-eval/rsem-build-read-index $PREFIX/bin/
cp -rf rsem-eval/rsem-eval-calculate-score $PREFIX/bin/
cp -rf rsem-eval/rsem-eval-estimate-transcript-length-distribution $PREFIX/bin/
cp -rf rsem-eval/rsem-eval-run-em $PREFIX/bin/
cp -rf rsem-eval/rsem-extract-reference-transcripts $PREFIX/bin/
cp -rf rsem-eval/rsem-parse-alignments $PREFIX/bin/
cp -rf rsem-eval/rsem_perl_utils.pm $PREFIX/bin/
cp -rf rsem-eval/rsem-plot-model $PREFIX/bin/
cp -rf rsem-eval/rsem-preref $PREFIX/bin/
cp -rf rsem-eval/rsem-sam-validator $PREFIX/bin/
cp -rf rsem-eval/rsem-scan-for-paired-end-reads $PREFIX/bin/
cp -rf rsem-eval/rsem-simulate-reads $PREFIX/bin/
cp -rf rsem-eval/rsem-synthesis-reference-transcripts $PREFIX/bin/
cp -rf rsem-eval/rsem_perl_utils.pm $PREFIX/bin/
