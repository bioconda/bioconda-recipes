#!/bin/bash

set -eu -o pipefail

work_dir=$PREFIX/pasta-build
install_dir=$PREFIX/bin

mkdir -p $work_dir
mkdir -p $work_dir/pasta

cp -R ./* $work_dir/pasta
cd $work_dir

unamestr=`uname`
if [ $unamestr == 'Linux' ];
then
    wget --no-check-certificate https://github.com/smirarab/sate-tools-linux/archive/a3e6f56.tar.gz
    tar -xzf a3e6f56.tar.gz
    mv sate-tools-linux-a3e6f56372599ffacf1bd43adb2d67cf361228e2 sate-tools-linux
    cd pasta
    $PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
    mkdir $install_dir/sate-tools-linux
    cp -R $work_dir/sate-tools-linux/* $install_dir/sate-tools-linux/
    # Handle a PASTA bug.
    cp $install_dir/sate-tools-linux/hmmalign $install_dir/sate-tools-linux/hmmeralign
    cp $install_dir/sate-tools-linux/hmmbuild $install_dir/sate-tools-linux/hmmerbuild
    # So tools are available in the bin directory.
    ln -s $install_dir/sate-tools-linux/* $install_dir/
elif [ $unamestr == 'Darwin' ];
then
    export DYLD_LIBRARY_PATH=$PREFIX/lib
    wget --no-check-certificate https://github.com/smirarab/sate-tools-mac/archive/0712214.tar.gz
    tar -xzf 0712214.tar.gz
    mv sate-tools-mac-0712214e20152b2ec989fc102602afa53d3a7b1a sate-tools-mac
    cd pasta
    $PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
    mkdir $install_dir/sate-tools-mac
    cp -R $work_dir/sate-tools-mac/* $install_dir/sate-tools-mac/
    # Handle a PASTA bug.
    cp $install_dir/sate-tools-mac/hmmalign $install_dir/sate-tools-mac/hmmeralign
    cp $install_dir/sate-tools-mac/hmmbuild $install_dir/sate-tools-mac/hmmerbuild
    # So tools are available in the bin directory.
    ln -s $install_dir/sate-tools-mac/* $install_dir/
fi

mkdir $install_dir/pasta
cp -R $work_dir/pasta/* $install_dir/pasta/
