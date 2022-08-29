#!/bin/bash

cd "${SRC_DIR}/Code"
cmake .
cmake --build .

mkdir -p "${PREFIX}/bin"
echo "dir written ${PREFIX}/bin"
cp -a ${SRC_DIR}/Code/. ${PREFIX}/bin
ls ${PREFIX}/bin

