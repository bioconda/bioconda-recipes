#!/bin/bash
make \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -Wall -O3 -funroll-loops" \
    EXEDIR="${PREFIX}/bin/"
