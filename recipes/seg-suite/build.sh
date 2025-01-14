#! /bin.bash

make

find . -type d -name "*.dSYM" -exec rm -rf {} +

make install prefix=$PREFIX