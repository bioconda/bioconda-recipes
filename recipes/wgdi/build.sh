#!/bin/bash

# build 
$PYTHON -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv

echo "[ini]
mafft_path = ${PREFIX}/bin/mafft
pal2nal_path = ${PREFIX}/bin/pal2nal.pl
yn00_path = ${PREFIX}/bin/yn00
muscle_path = ${PREFIX}/bin/muscle
iqtree_path =  ${PREFIX}/bin/iqtree
trimal_path = ${PREFIX}/bin/trimal
fasttree_path = ${PREFIX}/bin/fasttree
divvier_path = ${PREFIX}/bin/divvier " > $SP_DIR/wgdi/example/conf.ini
