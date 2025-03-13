#!/bin/bash -euo

mkdir -p "${PREFIX}/bin"

make -C src release -j"${CPU_COUNT}"

chmod +x $SRC_DIR/src/Plot.R
cp -f $SRC_DIR/src/Plot.R ${PREFIX}/bin/

install -v -m 0755 src/PreProcessR src/subcontig src/hashcounter src/StrainR ${PREFIX}
