#!/bin/sh
"${CC}" -O3 -ffast-math -finline-functions -o aragorn aragorn1.2.41.c

mkdir -p "${PREFIX}/bin"
mv aragorn "${PREFIX}/bin/"
