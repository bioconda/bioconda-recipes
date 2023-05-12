#!/bin/sh

if [[ ${target_platform}  == osx-64 ]] ; then
    curl -SL https://github.com/brentp/somalier/archive/refs/tags/v${PKG_VERSION}.tar.gz -o somalier-latest.tar.gz
    tar -xzf somalier-latest.tar.gz
    cd somalier-${PKG_VERSION}
    nimble --localdeps build -y --verbose -d:release
else
    curl -SL https://github.com/brentp/somalier/releases/download/v$PKG_VERSION/somalier -o somalier
    chmod +x somalier
fi

mkdir -p "${PREFIX}/bin"
cp somalier "${PREFIX}/bin/"
