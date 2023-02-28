#!/bin/bash

cd src

if [[ ${target_platform} =~ osx.* ]]; then
make -f Makefile.MacOS OUR_CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
else
make -f Makefile.Linux OUR_CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
fi

install -d "${PREFIX}/bin"
install ../verse "${PREFIX}/bin/"
