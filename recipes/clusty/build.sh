#!/bin/bash
#ln -s ${CC} gcc
#ln -s ${CXX} g++
#export PATH=$PATH:$(pwd)
uname_S=`uname -s 2>/dev/null || echo not`

if [ "$uname_S" == "Darwin" ]; then make -j${CPU_COUNT}; else make -j${CPU_COUNT} LEIDEN=true; fi

install -d "${PREFIX}/bin"
install clusty "${PREFIX}/bin"
