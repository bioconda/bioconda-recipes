#!/bin/bash
$PYTHON -m pip install --no-deps --no-build-isolation --no-cache-dir . -vvv
echo "[software]
gffread = ${PREFIX}/bin/gffread
AnchorWave = ${PREFIX}/bin/anchorwave
diamond = ${PREFIX}/bin/diamond
blastp = ${PREFIX}/bin/blastp
blastn = ${PREFIX}/bin/blastn
makeblastdb = ${PREFIX}/bin/makeblastdb
muscle = ${PREFIX}/bin/muscle
mafft = ${PREFIX}/bin/mafft
yn00 = ${PREFIX}/bin/yn00
pal2nal = ${PREFIX}/bin/pal2nal.pl " > ${SP_DIR}/quota_anchor/config_file/software_path.ini
