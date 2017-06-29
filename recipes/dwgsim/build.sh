#!/bin/sh

set -x -e -o pipefail

(git clone http://github.com/samtools/samtools && cd samtools && git checkout 28391e5898804ce6b805016)

make LIBCURSES=-lncurses

mkdir -p $PREFIX/bin

cp dwgsim $PREFIX/bin
cp dwgsim_eval $PREFIX/bin

