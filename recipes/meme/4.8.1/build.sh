#!/bin/bash

MEME_ETC_DIR=${PREFIX}/etc
#HOME=/tmp cpanm YAML
#HOME=/tmp cpanm HTML::PullParser
#HOME=/tmp cpanm XML::Simple
#HOME=/tmp cpanm CGI
#HOME=/tmp cpanm HTML::Template
#HOME=/tmp cpanm HTML::Parse
#HOME=/tmp cpanm CGI::Application
#HOME=/tmp cpanm XML::Parser::Expat --configure-args "EXPATLIBPATH=$PREFIX/lib" --configure-args "EXPATHINCPATH=$PREFIX/include"
perl scripts/dependencies.pl
./configure --prefix="$PREFIX" --enable-build-libxml2 --enable-build-libxslt #--with-gnu-ld
make clean
make AM_CFLAGS='-DNAN="(0.0/0.0)"'
make install
