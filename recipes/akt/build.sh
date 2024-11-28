#!/bin/bash
if [ `uname -m` == "aarch64" ]; then
sed -i 's/\-mpopcnt//g' Makefile
fi

make \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
install ./akt "${PREFIX}/bin/"
