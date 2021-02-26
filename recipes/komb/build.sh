#!/bin/bash

./autogen.sh
./configure
make
make install
mkdir "${PREFIX}/bin"
cp komb "${PREFIX}/bin"
