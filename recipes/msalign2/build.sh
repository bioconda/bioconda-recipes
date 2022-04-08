#!/bin/bash
mkdir -p "${PREFIX}/bin"
"${CC}" ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -o "${PREFIX}/bin/msalign2" base64.c ramp.c msalign2.c -I. -lgd -lm -lz -std=gnu99
