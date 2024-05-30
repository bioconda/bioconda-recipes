#!/bin/bash

mkdir ${SRC_DIR}/build/
cd ${SRC_DIR}/build/
echo $SRC_DIR
cmake ${SRC_DIR}/src
cmake --build . --config Release

cp ${SRC_DIR}/build/main/megaX $PREFIX/main
chmod +x $PREFIX/main/megaX
