#!/bin/bash

mkdir -p build
cd build
cmake  ../src
cmake --build . --config Release

cp main/taxor $PREFIX/bin
chmod +x $PREFIX/bin/taxor