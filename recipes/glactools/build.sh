#!/bin/bash

make CC="${CC} ${CXX} -fcommon ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
make install INSTALLDIR="${PREFIX}/bin/"

