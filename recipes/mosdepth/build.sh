#!/bin/sh

if [[ ${target_platform}  == osx-64 ]] ; then
    curl -SL https://github.com/nim-lang/nightlies/releases/download/latest-version-1-6/macosx_x64.tar.xz -o macosx_x64.tar.xz
    tar -xzf macosx_x64.tar.xz
    cd nim-1.6.*
    export PATH="$PWD/bin:$PATH"
    cd ..
    curl -SL https://github.com/brentp/mosdepth/archive/refs/tags/v${PKG_VERSION}.tar.gz -o mosdepth-latest.tar.gz
    tar -xzf mosdepth-latest.tar.gz
    cd mosdepth-${PKG_VERSION}
    nimble install -y "docopt@0.7.0"
    nimble build -y --verbose -d:release
else
    curl -SL https://github.com/brentp/mosdepth/releases/download/v$PKG_VERSION/mosdepth_d4 -o mosdepth
    chmod +x mosdepth
fi

mkdir -p "${PREFIX}/bin"
cp mosdepth "${PREFIX}/bin/"
