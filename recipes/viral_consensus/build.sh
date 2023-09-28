#!/bin/bash

make
if [ ! -d "$PREFIX/bin" ]; then
    mkdir $PREFIX/bin;
    export PATH=$PREFIX/bin:$PATH;
fi
cp viral_consensus $PREFIX/bin/
