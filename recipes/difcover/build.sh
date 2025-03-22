#!/bin/bash

cd dif_cover_scripts/

rm from_unionbed_to_ratio_per_window_CC0
make CXX="${GXX} ${LDFLAGS}"

mkdir -p "${PREFIX}/bin"
cp from_unionbed_to_ratio_per_window_CC0 *.R *.sh "${PREFIX}/bin"
chmod +x ${PREFIX}/bin/*.sh
