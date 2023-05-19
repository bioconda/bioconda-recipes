#!/bin/bash
mkdir -p $PREFIX/bin

make CC=$CC CFLAGS="$CFLAGS -fcommon"
make install

binaries="\
bstats \
comppair \
conus_compare   \
conus_train   \
pModel   \
scompare  \
sfold  \
strain_ml \
"

for i in $binaries; do cp bin/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done
