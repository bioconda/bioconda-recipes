#!/bin/sh

cd src

if [ "$(uname)" = "Darwin" ]; then
    make -f Makefile_macos \
        CC="${CXX}" \
        G++FLAG="${CXXFLAGS} -std=c++17 -w -Wno-psabi" \
        I_PATH="-I../include -I${PREFIX}/include" \
        L_PATH="${PREFIX}/lib"
else
    make -f Makefile_linux \
        CXX="${CXX}" \
        CXXFLAGS="${CXXFLAGS} -std=c++17 -fno-pie" \
        LDFLAGS="${LDFLAGS} -no-pie" \
        I_PATH="-I../include -I${PREFIX}/include" \
        L_PATH="${PREFIX}/lib"
fi

install -d "${PREFIX}/bin"
install selscan "${PREFIX}/bin/"
