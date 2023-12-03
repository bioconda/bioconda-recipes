#!/bin/bash

set -eu -o pipefail

# obtain opal.jar from Siavash's extra repo
unamestr=`uname`
if [ $unamestr == 'Linux' ];
then
    wget --no-check-certificate https://github.com/smirarab/sate-tools-linux/raw/master/opal.jar -O $PREFIX/bin/opal.jar
    mkdir -p ../sate-tools-linux/mafftdir/bin ../sate-tools-linux/mafftdir/libexec  # fake existens of tool collection
elif [ $unamestr == 'Darwin' ];
then
    wget --no-check-certificate  https://github.com/smirarab/sate-tools-mac/raw/master/opal.jar -O $PREFIX/bin/opal.jar
    mkdir -p ../sate-tools-mac/mafftdir/bin ../sate-tools-mac/mafftdir/libexec  # fake existens of tool collection
fi

# Handle a PASTA bug.
ln -s $PREFIX/bin/hmmalign $PREFIX/bin/hmmeralign
ln -s $PREFIX/bin/hmmbuild $PREFIX/bin/hmmerbuild

# "rename" raxml binaries
ln -s $PREFIX/bin/raxmlHPC $PREFIX/bin/raxml
ln -s $PREFIX/bin/raxmlHPC-PTHREADS $PREFIX/bin/raxmlp

# copy files for tests to shared conda directory
mkdir -p $PREFIX/share/pasta/data/
cp -v data/small.fasta $PREFIX/share/pasta/data/

# install pasta itself
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
ln -s bin/treeshrink $PREFIX/bin/treeshrink

# ensure PASTA environment variable point to the right bin directory
echo 'export PASTA_TOOLS_RUNDIR=\$PREFIX/bin' > $PREFIX/etc/conda/activate.d/pasta_activate.sh
echo 'unset PASTA_TOOLS_RUNDIR' > $PREFIX/etc/conda/deactivate.d/pasta_deactivate.sh
