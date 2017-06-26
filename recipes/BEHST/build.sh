#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#
set -o nounset -o pipefail -o errexit
set -o xtrace

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
echo "build.sh outdir: "$outdir

echo "PREFIX: "$PREFIX

cd $PREFIX
cd ..
ls
cd ./work
ls
cd ./bin


./download_behst_data.sh