#!/bin/bash
ln -s ${CC} /usr/local/bin/gcc
ln -s ${CXX} /usr/local/bin/g++
make -j${CPU_COUNT}
install -d "${PREFIX}/bin"
install lz-ani "${PREFIX}/bin"
