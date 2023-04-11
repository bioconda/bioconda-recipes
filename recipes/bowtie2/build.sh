#!/bin/bash

LDFLAGS=""
make CXX=$CXX CPP=$CXX CC=$CC LDLIBS="-L$PREFIX/lib -lz -lzstd -ltbb -ltbbmalloc -lpthread" WITH_ZSTD=1

binaries="\
bowtie2 \
bowtie2-align-l \
bowtie2-align-s \
bowtie2-build \
bowtie2-build-l \
bowtie2-build-s \
bowtie2-inspect \
bowtie2-inspect-l \
bowtie2-inspect-s \
"
directories="scripts"
pythonfiles="bowtie2-build bowtie2-inspect"

for i in $binaries; do
    cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i
done

for d in $directories; do
    cp -r $d $PREFIX/bin
done
