#!/bin/bash

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" ]]; then
	export CFLAGS="${CFLAGS} -fno-define-target-os-macros"
fi

if [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
	export EXTRA_ARGS="--host=arm64"
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
elif [[ "${OS}" == "Linux" && "${ARCH}" == "aarch64" ]]; then
	export EXTRA_ARGS="--host=aarch64"
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
else
	export EXTRA_ARGS="--host=x86_64"
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
fi

export CFLAGS="${CFLAGS} -fcommon"

./configure --prefix=$PREFIX --without-x
make
make install

python $RECIPE_DIR/fix_acd_path.py $PREFIX/bin
chmod +x $PREFIX/bin/*
