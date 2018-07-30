#!/bin/bash
set -euo pipefail

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share
mkdir -p ${PREFIX}/share/dialign2

cd src

sed -i.bak "s|strcpy ( dialign_dir , \"DIALIGN2_DIR\" );|strcpy ( par_dir , \""${PREFIX}"/share/dialign2\" );|g" dialign.c

make
mv dialign2-2 ${PREFIX}/bin/dialign2-2

cd ../dialign2_dir
mv -t ${PREFIX}/share/dialign2 tp400_dna tp400_prot tp400_trans BLOSUM