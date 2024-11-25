#!/bin/bash

if [[ ${target_platform}  == "osx-64" ]] ; then
    curl -SL https://github.com/nim-lang/nightlies/releases/download/latest-version-2-2/macosx_x64.tar.xz -o macosx_x64.tar.xz
    tar -xzf macosx_x64.tar.xz
    cd nim-2.2.*
    export PATH="$PWD/bin:$PATH"
    cd ..

    curl -SL https://github.com/38/d4-format/archive/refs/tags/v0.3.11.tar.gz -o d4-format.tar.gz
    tar -xzf d4-format.tar.gz
    cp -rf d4-format-*/d4binding/include/d4.h $PREFIX/include/
    
    curl -SL https://github.com/brentp/mosdepth/archive/refs/tags/v${PKG_VERSION}.tar.gz -o mosdepth-latest.tar.gz
    tar -xzf mosdepth-latest.tar.gz
    cd mosdepth-${PKG_VERSION}
    
    nimble install -y "docopt@0.7.1"  --passC:"-I$PREFIX/include" --passL:"-L$PREFIX/lib"
    nimble build -y --verbose -d:release -d:d4 --passC:"-I$PREFIX/include" --passL:"-L$PREFIX/lib"
else
    #Link to mosdepth_d4 is specified below because of https://github.com/brentp/mosdepth/issues/232 
    curl -SL https://github.com/brentp/mosdepth/releases/download/v$PKG_VERSION/mosdepth_d4 -o mosdepth
    chmod +x mosdepth
fi

mkdir -p "${PREFIX}/bin"
chmod 0755 mosdepth
mv mosdepth "${PREFIX}/bin/"
