#!/bin/bash

set -eu -o pipefail

out_dir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
pasta_tools_dev_dir=$PREFIX/share
share_dir=$PREFIX/share

mkdir -p $out_dir
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/pasta

cp -R ./* $out_dir

unamestr=`uname`
if [ $unamestr == 'Linux' ];
then
    wget https://github.com/smirarab/sate-tools-linux/archive/master.tar.gz
    tar -xzf master.tar.gz
    mv sate-tools-linux-master $pasta_tools_dev_dir/sate-tools-linux
    cd $out_dir
    $PYTHON setup.py develop
    cp -R $share_dir/sate-tools-linux/* $PREFIX/bin
elif [ $unamestr == 'Darwin' ];
then
    wget https://github.com/smirarab/sate-tools-mac/archive/master.tar.gz
    tar -xzf master.tar.gz
    mv sate-tools-mac-master $pasta_tools_dev_dir/sate-tools-mac
    cd $out_dir
    $PYTHON setup.py develop
    cp -R $share_dir/sate-tools-mac/* $PREFIX/bin
fi

# There seemes to be a bug in this version of Pasta.  Executing the following
# with a valid input dataset:
#
# $python run_pasta.py -i input_fasta [-t starting_tree]
#
# produces the following error:
#
# PASTA ERROR: PASTA is exiting because of an error:
# '~/pasta/bin/hmmeralign' not found. Please install 'hmmeralign' and/or configure its location...
#
# Here is a work-around:
ln -s $PREFIX/bin/hmmalign $PREFIX/bin/hmmeralign
ln -s $PREFIX/bin/hmmbuild $PREFIX/bin/hmmerbuild

cp $out_dir/pasta/*.py $PREFIX/pasta
cp $out_dir/run*.py $PREFIX
