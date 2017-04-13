#!/bin/sh
set -x -e -o pipefile

(git clone http://github.com/samtools/samtools && cd samtools && git checkout 28391e5898804ce6b805016)

make

mkdir -p $PREFIX/bin

cp dwgsim $PREFIX/bin
cp dwgsim_eval $PREFIX/bin
cp scripts/dwgsim_eval_plot.py $PREFIX/bin

