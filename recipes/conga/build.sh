#!/bin/bash
set -ex

export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include -I${PREFIX}/include/htslib -I src"
export CFLAGS="${CFLAGS} -DCONGA_VERSION=\"${PKG_VERSION}\" -DBUILD_DATE=\"$(date)\" -DCONGA_UPDATE=\"April 9, 2026\""

SOURCES="src/svdepth.c src/cmdline.c src/common.c src/bam_data.c src/read_distribution.c src/free.c src/likelihood.c src/svs.c src/split_read.c src/genome.c"

for src in ${SOURCES}; do
    ${CC} -c ${CFLAGS} ${src} -o ${src%.c}.o
done

${CC} src/*.o -o conga -L${PREFIX}/lib -lhts -lz -lm -lpthread -llzma -lbz2 -lcurl

install -d "${PREFIX}/bin"
install -m 755 conga "${PREFIX}/bin/"
