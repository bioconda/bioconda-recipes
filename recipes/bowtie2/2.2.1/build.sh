#!/bin/bash
set -eu -o pipefail

make CXX=$CXX CPP=$CXX CC=$CC LDLIBS="-L$PREFIX/lib -lz -ltbb -ltbbmalloc -lpthread"

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

PY3_BUILD="${PY_VER%.*}"

if [ $PY3_BUILD -eq 3 ]
then
    for i in $pythonfiles; do 2to3 --write $i; done
fi

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
for d in $directories; do cp -r $d $PREFIX/bin; done

# Adding the Bowtie2 wrapper script to the path

SOURCE_FILE=$RECIPE_DIR/bowtie2_wrapper.sh
chmod +x $SOURCE_FILE
cp $SOURCE_FILE $PREFIX/bin
