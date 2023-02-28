#!/bin/bash
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

for prog in fastq bam gtf bed; do
  mkdir -p $PREFIX/share/ngsutils/$prog
  mv $SRC_DIR/ngsutils/$prog/README $PREFIX/share/ngsutils/$prog
done
cp LICENSE VERSION $PREFIX/share/ngsutils/

sed "3s~.*~DIR=$SP_DIR~g" $SRC_DIR/bin/ngsutils | \
sed '9s~$DIR~$PREFIX/share~g' | \
sed "27s~.*~~g" | \
sed "28s~.*~~g" | \
sed "s~cat VERSION~cat $PREFIX/share/ngsutils/VERSION~g" | \
sed 's~exec "$DIR"/ngsutils/$SUBDIR/$action "$@"~exec python "$DIR"/ngsutils/$SUBDIR/$action "$@"~g' > $SRC_DIR/bin/ngsutils.new
mv $SRC_DIR/bin/ngsutils.new $SRC_DIR/bin/ngsutils

$PYTHON -m pip install . --ignore-installed --no-deps -vv
