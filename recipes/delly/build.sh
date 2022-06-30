#!/bin/sh

mkdir -p "${PREFIX}/bin"
if [[ ${target_platform}  == osx-64 ]] ; then
    make all CXX=$CXX CXXFLAGS="-I${PREFIX}/include -L${PREFIX}/lib"
    cp src/delly "${PREFIX}/bin"
else
    wget "https://github.com/dellytools/delly/releases/download/v${PKG_VERSION}/delly_v${PKG_VERSION}_linux_x86_64bit"
    mv delly_v${PKG_VERSION}_linux_x86_64bit delly
    chmod +x delly
    cp delly "${PREFIX}/bin"
fi
