#!/bin/sh

aclocal
autoheader
automake --add-missing --foreign
autoconf

./configure --prefix=$HOME/entropy

make 
make install

