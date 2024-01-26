#!/bin/bash

mkdir ${SRC_DIR}/build/
cd ${SRC_DIR}/build/
cmake ${SRC_DIR}
cmake --build . --config Release

cp main/taxor $PREFIX/bin
chmod +x $PREFIX/bin/taxor