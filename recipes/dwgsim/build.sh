#!/bin/bash
set -e

(git clone http://github.com/samtools/samtools && cd samtools && git checkout 28391e5898804ce6b805016d8c676fdf61442eb3)

export CFLAGS="-I$PREFIX/include"
sed -i 's/CFLAGS=/CFLAGS+=/' Makefile
make CC=$CC LIBCURSES=-lncurses CFLAGS=$CFLAGS

mkdir -p $PREFIX/bin

cp dwgsim $PREFIX/bin
cp dwgsim_eval $PREFIX/bin
