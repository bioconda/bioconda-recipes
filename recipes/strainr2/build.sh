#!/bin/bash -euo

mkdir -p "${PREFIX}/bin"

${CC} ${SRC_DIR}/src/subcontig.c -O3 -o subcontig
${CC} ${SRC_DIR}/src/hashcounter.c -I$PREFIX/include -L$PREFIX/lib -O3 -o hashcounter -lz

chmod +x $SRC_DIR/src/PreProcessR
chmod +x $SRC_DIR/subcontig
chmod +x $SRC_DIR/hashcounter
chmod +x $SRC_DIR/src/Plot.R
chmod +x $SRC_DIR/src/StrainR

cp $SRC_DIR/src/PreProcessR ${PREFIX}/bin/
cp $SRC_DIR/subcontig ${PREFIX}/bin/
cp $SRC_DIR/hashcounter ${PREFIX}/bin/
cp $SRC_DIR/src/Plot.R ${PREFIX}/bin/
cp $SRC_DIR/src/StrainR ${PREFIX}/bin/
