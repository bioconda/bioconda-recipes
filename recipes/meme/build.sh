#!/bin/bash
set -e
MEME_ETC_DIR=${PREFIX}/etc
#HOME=/tmp cpanm CGI::Application
#HOME=/tmp cpanm XML::Parser::Expat --configure-args "EXPATLIBPATH=$PREFIX/lib" --configure-args "EXPATHINCPATH=$PREFIX/include"
perl scripts/dependencies.pl

./configure --prefix="$PREFIX"

make clean
make AM_CFLAGS='-DNAN="(0.0/0.0)"'

# tests will only work inside the build dir, but
# https://github.com/conda/conda-build/issues/1453
# so you need `conda build --prefix-length 1`
# for it to work properly
# make test

make install

ln -s $PREFIX/libexec/meme*/* $PREFIX/bin/

# if building with python3,
# modify meme-chip script to use python3 version of DREME
if [ $PY3K==1 ]; then
    sed -i.bak  '994s/dreme/dreme-py3/' $PREFIX/bin/meme-chip
    rm $PREFIX/bin/meme-chip.bak
fi

