#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#
set -o nounset -o pipefail -o errexit
set -o xtrace

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
echo "outdir: "$outdir

PREFIX=.

cd $PREFIX/bin/

mkdir $PREFIX/../results/

mkdir $PREFIX/../temp/

echo "outdir: "$outdir
sh project.sh $PREFIX/../data/pressto_LUNG_enhancers.bed DEFAULT_EQ DEFAULT_ET
