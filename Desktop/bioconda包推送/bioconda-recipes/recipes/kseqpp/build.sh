#!/usr/bin/env bash
cmake -S ${SRC_DIR} -B ${SRC_DIR}/build -DBUILD_TESTING=on -DCMAKE_INSTALL_PREFIX="${PREFIX}"
cmake --build ${SRC_DIR}/build --target install
