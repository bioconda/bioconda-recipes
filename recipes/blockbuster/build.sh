#!/bin/bash

mkdir -p "${PREFIX}/bin"

"${CC}" ${CPPFLAGS} ${CFLAGS} \
  -pedantic blockbuster.c \
  -o "${PREFIX}/bin/"blockbuster.x \
  ${LDFLAGS} \
  -lm -std=c99 -D_GNU_SOURCE
