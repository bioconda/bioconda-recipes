#!/bin/sh

set -x -e -o pipefail

(git clone http://github.com/samtools/samtools && cd samtools && git checkout 28391e5898804ce6b805016)

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

sed -i.bak 's/CFLAGS =/CFLAGS +=/' Makefile

make CC=$CC LIBCURSES=-lncurses CFLAGS=$CFLAGS LDFLAGS=$LDFLAGS

mkdir -p $PREFIX/bin

cp dwgsim $PREFIX/bin
cp dwgsim_eval $PREFIX/bin

