#!/bin/bash
set -x

cd src/
make CC=$GCC CPP=$GXX
make install
