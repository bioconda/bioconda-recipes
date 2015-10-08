#!/bin/bash

mkdir -p $PREFIX/bin

binaries="\
bowtie \
bowtie-align-l \
bowtie-align-s \
bowtie-build \
bowtie-build-l \
bowtie-build-s \
bowtie-inspect \
bowtie-inspect-l \
bowtie-inspect-s \
"
pythonfiles="bowtie-build bowtie-inspect"

PY3_BUILD="${PY_VER%.*}"

if [ $PY3_BUILD -eq 3 ]
then
    for i in $pythonfiles; do 2to3 --write $i; done
fi

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
