#!/bin/sh

aclocal
autoconf
automake --add-missing --foreign

./configure --prefix=$HOME/entropy

make 
make install

