#!/bin/bash
$PYTHON -m pip install . -vvv --no-deps --no-build-isolation --no-cache-dir --ignore-installed
echo "[software]
gffread = ${PREFIX}/bin/gffread
AnchorWave = ${PREFIX}/bin/anchorwave
diamond = ${PREFIX}/bin/diamond
blastp = ${PREFIX}/bin/blastp
makeblastdb = ${PREFIX}/bin/makeblastdb
muscle = ${PREFIX}/bin/muscle
mafft = ${PREFIX}/bin/mafft
yn00 = ${PREFIX}/bin/yn00
pal2nal = ${PREFIX}/bin/pal2nal.pl " > ${SP_DIR}/quota_anchor/config_file/software_path.ini
