#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
    make GSL_PATH=$PREFIX/ CC=$CXX MAC=1 SHELL=/bin/bash
else
    make GSL_PATH=$PREFIX/ CC=$CXX SHELL=/bin/bash
fi

make install BIN_INSTALL=$PREFIX/bin/ LIB_INSTALL=$PREFIX/lib/ SHELL=/bin/bash
