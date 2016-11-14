#!/bin/bash

set -o pipefail

#mkdir -p $PREFIX/bin
#mkdir -p $PREFIX/lib
#mkdir -p $PREFIX/include

#rsync -a bin/ $PREFIX/bin
#rsync -a lib/ $PREFIX/lib
#rsync -a include/ $PREFIX/include

cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$PREFIX

make

make install

