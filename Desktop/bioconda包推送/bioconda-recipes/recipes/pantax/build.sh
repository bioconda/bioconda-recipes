#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
    cp -rf $SRC_DIR $PREFIX
else
    cd ${SRC_DIR}/scripts
    chmod +x pantax data_preprocessing pantax_utils
    cp ${SRC_DIR}/scripts/pantax ${SRC_DIR}/scripts/data_preprocessing ${SRC_DIR}/scripts/pantax_utils ${PREFIX}/bin
    cp ${SRC_DIR}/scripts/*py ${PREFIX}/bin

    cd ${SRC_DIR}/tools/fastix
    RUST_BACKTRACE=1 cargo install --verbose --locked --no-track --root ${PREFIX} --path .
fi
