#!/bin/sh

make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
make install INSTALLDIR="${PREFIX}/bin/"
