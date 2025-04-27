#!/bin/bash

mkdir -p "${PREFIX}"/bin

cd src

${CC} -c -o irf.o irf.3.c -O3
${CC} -c -o easylife.o easylife.c -O3
${CC} -o ${PREFIX}/bin/irf irf.o easylife.o -lm
rm -f *.o
