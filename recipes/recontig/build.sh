#!/bin/bash

# linking htslib, see:
# http://pysam.readthedocs.org/en/latest/installation.html#external
# https://github.com/pysam-developers/pysam/blob/v0.9.0/setup.py#L79

echo "Downloading D compiler"
curl -fsS https://dlang.org/install.sh -o install.sh
chmod +x install.sh
DENV=$(./install.sh ldc-1.26.0 -p $PWD -a)
. $DENV

cd $SRC_DIR
echo "building recontig binary"
export LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
dub build -b release -c bioconda
cp ldc-1.26.0/lib/* $PREFIX/lib
deactivate

export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
./recontig
cp recontig $PREFIX/bin

export HTSLIB_DIR=$PREFIX/lib
# $PYTHON -m pip install --upgrade pip
# pip install pyd
echo "installing pyd"
git clone https://github.com/ariovistus/pyd.git
cd pyd
echo "$CC"
git checkout v0.14.1
CC="$CC" $PYTHON setup.py install
cd ..
echo "installing recontig python package"
. $DENV
ln -s $CC $PREFIX/bin/gcc
$PYTHON setup.py build --compiler ldc
$PYTHON setup.py install 
deactivate
rm $PREFIX/bin/gcc