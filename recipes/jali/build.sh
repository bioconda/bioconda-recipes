# !/bin/bash

make

binaries="\
jscan \
jali \
jsearch \
"

mkdir -p $PREFIX/bin
for i in $binaries; do cp $SRC_DIR/$i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done