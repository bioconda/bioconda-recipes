#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#
set -o nounset -o pipefail -o errexit
set -o xtrace

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
echo "test.sh outdir: "$outdir

echo "PREFIX: "$PREFIX

cd $PREFIX
cd ..
ls
cd ./work/bin/


./project.sh ../data/pressto_BLOOD_enhancers.bed DEFAULT_EQ DEFAULT_ET

./project.sh ../data/vista_LIMB_sorted.bed DEFAULT_EQ DEFAULT_ET