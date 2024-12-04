#!/bin/sh
set -x
if [[ ${target_platform}  == osx-64 ]] || [[ ${target_platform}  == linux-aarch64 ]] ; then
    if [[ ${target_platform}  == osx-64 ]]; then
	nim_build="macosx_x64"
    else 
	nim_build="linux_arm64"
    fi
    curl -SL https://github.com/nim-lang/nightlies/releases/download/latest-version-1-6/${nim_build}.tar.xz -o ${nim_build}.tar.xz
    unxz -c ${nim_build}.tar.xz | tar  -x
    cd nim-1.6.*
    export PATH="$PWD/bin:$PATH"
    cd ..
    curl -SL https://github.com/brentp/mosdepth/archive/refs/tags/v${PKG_VERSION}.tar.gz -o mosdepth-latest.tar.gz
    tar -xzf mosdepth-latest.tar.gz
    cd mosdepth-${PKG_VERSION}
    nimble install -y "docopt@0.7.0"
    which gcc			# seems to not be found by nimble build..
    echo $PATH
    ls $PREFIX/bin/gcc
    nimble build -y --verbose -d:release --cc:$CC
else
    curl -SL https://github.com/brentp/mosdepth/releases/download/v$PKG_VERSION/mosdepth_d4 -o mosdepth
    chmod +x mosdepth
fi

mkdir -p "${PREFIX}/bin"
cp mosdepth "${PREFIX}/bin/"
