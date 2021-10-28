#!/bin/bash

mkdir -p $PREFIX/etc/conda/activate.d/
echo "export ASSEMBLY_STATS_SOURCE_DIR=$PREFIX/opt/assembly-stats" > $PREFIX/etc/conda/activate.d/rjchallis-assembly-stats-sourcedir.sh
chmod a+x $PREFIX/etc/conda/activate.d/rjchallis-assembly-stats-sourcedir.sh

mkdir -p $PREFIX/etc/conda/deactivate.d/
echo "unset ASSEMBLY_STATS_SOURCE_DIR" > $PREFIX/etc/conda/deactivate.d/rjchallis-assembly-stats-sourcedir.sh
chmod a+x $PREFIX/etc/conda/deactivate.d/rjchallis-assembly-stats-sourcedir.sh

mkdir -p "${PREFIX}/opt/assembly-stats" "${PREFIX}/bin"

cp assembly-stats.html "${PREFIX}/opt/assembly-stats/"
cp -r js "${PREFIX}/opt/assembly-stats/"
cp -r css "${PREFIX}/opt/assembly-stats/"

cp pl/asm2stats.minmaxgc.pl "${PREFIX}/bin"
cp pl/asm2stats.pl "${PREFIX}/bin"
chmod +x "${PREFIX}/bin/asm2stats.minmaxgc.pl"
chmod +x "${PREFIX}/bin/asm2stats.pl"

sed -i.bak 's|/usr/bin/perl -w|/usr/bin/env perl|' "${PREFIX}/bin/asm2stats.minmaxgc.pl" "${PREFIX}/bin/asm2stats.pl"
rm "${PREFIX}/bin/asm2stats.pl.bak"
