#!/bin/bash

# Download gsl: unsure why gsl dep not working
wget ftp://ftp.gnu.org/gnu/gsl/gsl-1.16.tar.gz
tar -xvzf gsl-1.16.tar.gz
cd gsl-1.16 && ./configure --prefix=${PREFIX}/lib && make && make install
cd ..

./configure CPPFLAGS=-I${PREFIX}/lib --prefix=$PREFIX
make
make install
