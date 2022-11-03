#!/bin/bash

./autogen.sh
./configure
make
make install
mkdir -p "${PREFIX}/bin"
cp komb "${PREFIX}/bin"
