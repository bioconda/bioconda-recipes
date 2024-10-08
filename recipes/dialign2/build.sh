#!/bin/bash
set -euo pipefail

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share
mkdir -p ${PREFIX}/share/dialign2

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -L${PREFIX}/lib"

if [[ `uname` == "Darwin" ]]; then
	export CFLAGS="${CFLAGS} -Wno-implicit-int -Wno-implicit-function-declaration"
else
	export CFLAGS="${CFLAGS}"
fi

cd src

sed -i.bak "s|strcpy ( dialign_dir , \"DIALIGN2_DIR\" );|strcpy ( par_dir , \""${PREFIX}"/share/dialign2\" );|g" dialign.c
rm -rf *.bak

make CC="${CC}" CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"
chmod 0755 dialign2-2
mv dialign2-2 ${PREFIX}/bin/dialign2-2

cd ../dialign2_dir
mv -t ${PREFIX}/share/dialign2 tp400_dna tp400_prot tp400_trans BLOSUM
