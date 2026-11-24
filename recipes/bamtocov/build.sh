#!/bin/bash
set -euxo pipefail

if [[ "$(uname -m)" == "arm64" ]]; then
    nim_build="macosx_arm64"
    curl -SL https://github.com/nim-lang/nightlies/releases/download/latest-version-2-2/${nim_build}.tar.xz -o ${nim_build}.tar.xz
    unxz -c ${nim_build}.tar.xz | tar -x
    cd nim-2.2.*
    export PATH="${PWD}/bin:${PATH}"
    cd ..
fi

if [[ $OSTYPE == "darwin"* ]]; then
    export HOME=`pwd`
fi

export LD_LIBRARY_PATH="$PREFIX"/lib

nim --version

nimble build -y --verbose  -d:release --opt:speed
mkdir -p "$PREFIX"/bin

pwd
ls -l bin/*

# Copy binaries
chmod a+x bin/*
cp bin/* "$PREFIX"/bin/

# Auxiliary python scripts
chmod a+x scripts/*.py
cp scripts/*.py "$PREFIX"/bin
