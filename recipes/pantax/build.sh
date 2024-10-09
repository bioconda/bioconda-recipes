#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
    cp -rf $SRC_DIR $PREFIX
else
    cd ${SRC_DIR}/scripts
    chmod +x pantax
    chmod +x data_preprocessing
    cp ${SRC_DIR}/scripts/pantax ${SRC_DIR}/scripts/data_preprocessing ${PREFIX}/bin
    cp ${SRC_DIR}/scripts/*py ${PREFIX}/bin

    mkdir -p ${PREFIX}/bin/tools
    cd ${SRC_DIR}/tools/fastix
    cargo install fastix --root ./
    cp ${SRC_DIR}/tools/fastix/bin/fastix ${PREFIX}/bin/tools
fi
