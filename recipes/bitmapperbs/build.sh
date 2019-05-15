#!/bin/bash
chmod +x htslib/version.sh

make -f ${RECIPE_DIR}/newMakefile PREFIX=${PREFIX}

mkdir -p ${PREFIX}/bin
mv psascan ${PREFIX}/bin/
mv bitmapperBS ${PREFIX}/bin/
