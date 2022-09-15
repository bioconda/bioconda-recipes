#!/bin/sh

make CC="${CC} -fcommon ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
make install INSTALLDIR="${PREFIX}/bin/"
