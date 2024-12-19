#!/bin/bash

set -x -e

PWD="$(pwd)"
SOURCE_CFG="${PWD}/path.cfg"
TARGET_CFG="${PREFIX}/etc/path.cfg"
SOURCE_PY="${PWD}/src/py/predict_3Di_encoderOnly.py"
TARGET_PY="${PREFIX}/etc/predict_3Di_encoderOnly.py"

mkdir -p "${PREFIX}/etc"
cp ${SOURCE_CFG} ${TARGET_CFG}
cp ${SOURCE_PY} ${TARGET_PY}

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install -v --locked --no-track --root $PREFIX --path .
