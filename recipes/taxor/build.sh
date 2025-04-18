#!/bin/bash

mkdir ${SRC_DIR}/build/
cd ${SRC_DIR}/build/
cmake ${SRC_DIR}/src
cmake --build . --config Release

cp ${SRC_DIR}/build/main/taxor $PREFIX/bin
chmod +x $PREFIX/bin/taxor

