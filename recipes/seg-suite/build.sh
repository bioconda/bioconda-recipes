#! /bin.bash

export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"

make

find . -type d -name "*.dSYM" -exec rm -rf {} +

make install prefix=$PREFIX