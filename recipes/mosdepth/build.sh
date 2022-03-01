#!/bin/sh

if [[ ${target_platform}  == osx-64 ]] ; then
    curl -SL https://github.com/brentp/mosdepth/archive/refs/tags/v${PKG_VERSION}.tar.gz -o mosdepth-latest.tar.gz
    tar -xzf mosdepth-latest.tar.gz
    cd mosdepth-latest
    nimble --localdeps build -y --verbose -d:release
else
    curl -SL https://github.com/brentp/mosdepth/releases/download/v$PKG_VERSION/mosdepth -o mosdepth
    chmod +x mosdepth
fi

mkdir -p "${PREFIX}/bin"
cp mosdepth "${PREFIX}/bin/"
