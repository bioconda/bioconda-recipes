#!/bin/bash

"${CC}" ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -o wgsim wgsim.c -lz -lm

mkdir "${PREFIX}/bin"
cp wgsim wgsim_eval.pl "${PREFIX}/bin/"

