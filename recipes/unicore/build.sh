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

case $(uname) in
	Darwin) rustup default stable && rustup target add x86_64-apple-darwin ;;
esac

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install -v --locked --no-track --root $PREFIX --path .
