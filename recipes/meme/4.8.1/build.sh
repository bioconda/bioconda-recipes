#!/bin/bash
MEME_ETC_DIR=${PREFIX}/etc
cpanm YAML
cpanm HTML::PullParser
cpanm XML::Simple
cpanm CGI
cpanm HTML::Template
cpanm HTML::Parse
cpanm CGI::Application
cpanm XML::Parser::Expat --configure-args "EXPATLIBPATH=$PREFIX/lib" --configure-args "EXPATHINCPATH=$PREFIX/include"

./configure --prefix="$PREFIX" --with-gnu-ld

make clean
make AM_CFLAGS='-DNAN="(0.0/0.0)"'

# tests will only work inside the build dir, but
# https://github.com/conda/conda-build/issues/1453
# so you need `conda build --prefix-length 1`
# for it to work properly
# make test

make install

