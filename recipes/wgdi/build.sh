#!/bin/bash

# build 
$PYTHON -m pip install . --no-deps --ignore-installed -vv

echo "[ini]
mafft_path = ${PREFIX}/bin/mafft
pal2nal_path = ${PREFIX}/bin/pal2nal.pl
yn00_path = ${PREFIX}/bin/yn00
muscle_path = ${PREFIX}/bin/muscle
iqtree_path =  ${PREFIX}/bin/iqtree" > $SP_DIR/wgdi/example/conf.ini

