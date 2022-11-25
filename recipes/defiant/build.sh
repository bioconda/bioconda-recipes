#!/bin/bash

"${CC}" ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -O4 -o defiant defiant.c -Wall -pedantic -std=gnu11 -lm -fopenmp 
"${CC}" ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -o roi roi.c -lm -Wall -std=gnu11 -Wextra -pedantic -Wconversion

install -d "${PREFIX}/bin"
install \
    defiant \
    roi \
    "${PREFIX}/bin/"
