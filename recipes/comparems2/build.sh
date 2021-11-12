#!/bin/bash
mkdir -p "${PREFIX}/bin"
"${CC}" ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -o "${PREFIX}/bin/compareMS2" compareMS2.c -lm
