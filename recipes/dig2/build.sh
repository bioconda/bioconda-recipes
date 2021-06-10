#!/bin/bash
mkdir -p "${PREFIX}/bin"
"${CC}" ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -O3 -o "${PREFIX}/bin/dig2" dig2.c -lm
