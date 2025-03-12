#!/bin/bash -euo

mkdir -p "${PREFIX}/bin"

make -C src release

chmod +x $SRC_DIR/src/PreProcessR
chmod +x $SRC_DIR/src/subcontig
chmod +x $SRC_DIR/src/hashcounter
chmod +x $SRC_DIR/src/Plot.R
chmod +x $SRC_DIR/src/StrainR

cp $SRC_DIR/src/PreProcessR ${PREFIX}/bin/
cp $SRC_DIR/src/subcontig ${PREFIX}/bin/
cp $SRC_DIR/src/hashcounter ${PREFIX}/bin/
cp $SRC_DIR/src/Plot.R ${PREFIX}/bin/
cp $SRC_DIR/src/StrainR ${PREFIX}/bin/
