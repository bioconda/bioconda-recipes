#!/bin/bash
MEME_ETC_DIR=${PREFIX}/etc
HOME=/tmp cpanm YAML
HOME=/tmp cpanm HTML::PullParser
HOME=/tmp cpanm XML::Simple
HOME=/tmp cpanm CGI
HOME=/tmp cpanm HTML::Template
HOME=/tmp cpanm HTML::Parse
HOME=/tmp cpanm CGI::Application
HOME=/tmp cpanm XML::Parser::Expat --configure-args "EXPATLIBPATH=$PREFIX/lib" --configure-args "EXPATHINCPATH=$PREFIX/include"

./configure --prefix="$PREFIX" --with-gnu-ld

make clean
make AM_CFLAGS='-DNAN="(0.0/0.0)"'

# tests will only work inside the build dir, but
# https://github.com/conda/conda-build/issues/1453
# so you need `conda build --prefix-length 1`
# for it to work properly
# make test

make install

