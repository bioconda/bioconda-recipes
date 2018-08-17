#!/bin/sh
set -x -e

export C_INCLUDE_PATH="${PREFIX}/include"
export CPP_INCLUDE_PATH="${PREFIX}/include"
export CXX_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

find -name Makefile | xargs -I {} sed -i.bak 's/-lcurses/-lncurses -ltinfo/g' {}

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
