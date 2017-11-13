#!/bin/bash
set -eu -o pipefail

make EXTRA_FLAGS="-I${PREFIX}/include -L${PREFIX}/lib"

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
directories="scripts"
pythonfiles="bowtie bowtie-build bowtie-inspect"

PY3_BUILD="${PY_VER%.*}"

if [ $PY3_BUILD -eq 3 ]
then
    for i in $pythonfiles; do 2to3 --write $i; done
fi

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
for d in $directories; do cp -r $d $PREFIX/bin; done
