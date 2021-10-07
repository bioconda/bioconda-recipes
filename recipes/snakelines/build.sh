#!/bin/bash

mkdir -pv $PREFIX/bin/
mkdir -pv $PREFIX/share/snakelines

echo \#\!\/bin/bash > snakelines
echo >> snakelines
echo 'SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"' >> snakelines
echo "snakemake --snakefile \$SCRIPTPATH/../share/snakelines/snakelines.snake \$@" >> snakelines

cp -rv snakelines $PREFIX/bin/
chmod ugo+x $PREFIX/bin/snakelines

cp -rv docs enviroments example legacy pipeline rules src License.txt README.rst config.yaml snakelines.snake $PREFIX/share/snakelines
