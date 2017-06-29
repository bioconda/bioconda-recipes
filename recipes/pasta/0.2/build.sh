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
    wget --no-check-certificate https://github.com/smirarab/sate-tools-linux/archive/a3e6f56.tar.gz
    tar -xzf a3e6f56.tar.gz
    mv sate-tools-linux-a3e6f56372599ffacf1bd43adb2d67cf361228e2 sate-tools-linux
    mv sate-tools-linux $pasta_tools_dev_dir
    cd $out_dir
    $PYTHON setup.py install
    cp -R $share_dir/sate-tools-linux/* $PREFIX/bin
elif [ $unamestr == 'Darwin' ];
then
    export DYLD_LIBRARY_PATH=$PREFIX/lib
    wget --no-check-certificate https://github.com/smirarab/sate-tools-mac/archive/0712214.tar.gz
    tar -xzf 0712214.tar.gz
    mv sate-tools-mac-0712214e20152b2ec989fc102602afa53d3a7b1a sate-tools-mac
    mv sate-tools-mac $pasta_tools_dev_dir
    cd $out_dir
    $PYTHON setup.py install
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

# Allow for calling "pasta" from the command line.
ln -s $PREFIX/run_pasta.py $PREFIX/bin/pasta

