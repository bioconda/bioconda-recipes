#!/bin/bash

mkdir -p "${PREFIX}/bin"

ARCH=$(uname -m)

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ ${target_platform}  == "osx-64" ]]; then
    curl -SL https://github.com/nim-lang/nightlies/releases/download/latest-version-1-6/macosx_x64.tar.xz -o macosx_x64.tar.xz
    tar -xzf macosx_x64.tar.xz
    cd nim-1.6.*
    export PATH="${PWD}/bin:${PATH}"
    cd ..
    curl -SL https://github.com/brentp/mosdepth/archive/refs/tags/v${PKG_VERSION}.tar.gz -o mosdepth-latest.tar.gz
    tar -xzf mosdepth-latest.tar.gz
    cd mosdepth-${PKG_VERSION}
    nimble install -y "docopt@0.7.0"
    nimble build -y --verbose -d:release
elif [[ "${ARCH}" == "aarch64" ]]; then
    curl -SL https://github.com/nim-lang/nightlies/releases/download/latest-version-1-6/linux_arm64.tar.xz -o linux_arm64.tar.xz
    tar -xf linux_arm64.tar.xz
    cd nim-1.6.*
    export PATH="${PWD}/bin:${PATH}"
    cd ..
    curl -SL https://github.com/brentp/mosdepth/archive/refs/tags/v${PKG_VERSION}.tar.gz -o mosdepth-latest.tar.gz
    tar -xf mosdepth-latest.tar.gz
    cd mosdepth-${PKG_VERSION}
    nimble install -y "docopt@0.7.0"
    CC="${CC}" nimble build -y --verbose -d:release
else
    curl -SL https://github.com/brentp/mosdepth/releases/download/v$PKG_VERSION/mosdepth -o mosdepth
    chmod 755 mosdepth
fi

chmod 755 mosdepth
cp -f mosdepth "${PREFIX}/bin/"
