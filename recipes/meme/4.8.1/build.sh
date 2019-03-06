#!/bin/bash

MEME_ETC_DIR=${PREFIX}/etc
#cpanm YAML
#cpanm HTML::PullParser
#cpanm XML::Simple
#cpanm CGI
#cpanm HTML::Template
#cpanm HTML::Parse
HOME=/tmp cpanm CGI::Application
HOME=/tmp cpanm XML::Parser::Expat --configure-args "EXPATLIBPATH=$PREFIX/lib" --configure-args "EXPATHINCPATH=$PREFIX/include"
perl scripts/dependencies.pl
./configure --prefix="$PREFIX" #--with-gnu-ld --enable-build-libxml2 --enable-build-libxslt
make clean
make AM_CFLAGS='-DNAN="(0.0/0.0)"'
make install
