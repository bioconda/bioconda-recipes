#!/bin/bash -euo

mkdir -p "${PREFIX}/bin"

${CC} ${SRC_DIR}/subcontig.c -o subcontig

chmod +x $SRC_DIR/PreProcessR
chmod +x $SRC_DIR/subcontig
chmod +x $SRC_DIR/hashcounter.py
chmod +x $SRC_DIR/Plot.R
chmod +x $SRC_DIR/StrainR

cp $SRC_DIR/PreProcessR ${PREFIX}/bin/
cp $SRC_DIR/subcontig ${PREFIX}/bin/
cp $SRC_DIR/hashcounter.py ${PREFIX}/bin/
cp $SRC_DIR/Plot.R ${PREFIX}/bin/
cp $SRC_DIR/StrainR ${PREFIX}/bin/
