#! /bin.bash

export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"

make
make install prefix=$PREFIX