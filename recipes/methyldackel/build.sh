#!/bin/bash
export C_INCLUDE_PATH=$PREFIX/include
make
make install prefix=$PREFIX/bin
