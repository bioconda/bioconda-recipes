#!/bin/bash

cd dif_cover_scripts/

rm from_unionbed_to_ratio_per_window_CC0
make

mkdir -p "${PREFIX}/bin"
cp from_unionbed_to_ratio_per_window_CC0 *.sh "${PREFIX}/bin"
