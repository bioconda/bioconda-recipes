#!/bin/bash

set -eu -o pipefail

# obtain opal.jar from Siavash's extra repo
unamestr=`uname`
if [[ $unamestr == 'Linux' ]];
then
    wget --no-check-certificate https://github.com/smirarab/sate-tools-linux/raw/master/opal.jar -O $PREFIX/bin/opal.jar
    mkdir -p ../sate-tools-linux/mafftdir/bin ../sate-tools-linux/mafftdir/libexec  # fake existens of tool collection
elif [[ $unamestr == 'Darwin' ]];
then
    wget --no-check-certificate  https://github.com/smirarab/sate-tools-mac/raw/master/opal.jar -O $PREFIX/bin/opal.jar
    mkdir -p ../sate-tools-mac/mafftdir/bin ../sate-tools-mac/mafftdir/libexec  # fake existens of tool collection
fi

# Handle a PASTA bug.
ln -sf $PREFIX/bin/hmmalign $PREFIX/bin/hmmeralign
ln -sf $PREFIX/bin/hmmbuild $PREFIX/bin/hmmerbuild

# copy files for tests to shared conda directory
mkdir -p $PREFIX/share/pasta/data/
cp -fv data/small.fasta $PREFIX/share/pasta/data/

# install pasta itself
sed -i.bak 's/^.*import imp/#&/g' pasta/__init__.py
sed -i.bak 's/^.*imp.is_frozen.*/#&/g' pasta/__init__.py
rm -rf pasta/*.bak
$PYTHON -m pip install --no-deps --no-build-isolation --no-cache-dir --use-pep517 . -vvv
cp -f bin/treeshrink $PREFIX/bin/treeshrink

# "rename" raxml binaries, after pasta's setup.py did copy bundled raxml versions into bin/
rm -fv $PREFIX/bin/raxml #$PREFIX/bin/raxmlp
cp -fv $PREFIX/bin/raxmlHPC $PREFIX/bin/raxml && chmod 0755 $PREFIX/bin/raxml
#cp -fv $PREFIX/bin/raxmlHPC-PTHREADS $PREFIX/bin/raxmlp && chmod 0755 $PREFIX/bin/raxmlp
