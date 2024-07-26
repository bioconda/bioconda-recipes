#!/bin/bash
ln -s ${CC} gcc
ln -s ${CXX} g++
make -j${CPU_COUNT}
install -d "${PREFIX}/bin"
install lz-ani "${PREFIX}/bin"
