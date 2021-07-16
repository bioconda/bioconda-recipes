#!/bin/bash

# downloading D compiler
echo "Downloading ldc2 1.26.0 D compiler"
curl -fsS https://dlang.org/install.sh -o install.sh
chmod +x install.sh
DENV=$(./install.sh ldc-1.26.0 -p $PWD -a)

# activating D compiler env
. $DENV

# build recontig binary
cd $SRC_DIR
echo "building recontig binary"
export LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
dub build -b release -c bioconda
cp ldc-1.26.0/lib/* $PREFIX/lib
deactivate

# run binary as test and move binary to bin
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
./recontig
cp recontig $PREFIX/bin

# Turning off python building for osx
if [ "$(uname)" != "Darwin" ]; then
    export HTSLIB_DIR=$PREFIX/lib

    # install pyd via github as pip doesn't work
    echo "installing pyd"
    git clone https://github.com/ariovistus/pyd.git
    cd pyd
    echo "$CC"
    git checkout v0.14.1
    CC="$CC" $PYTHON setup.py install
    cd ..
    
    # install recontig python extension
    echo "installing recontig python package"
    . $DENV
    # pyd doesn't like not having gcc 
    # availiable
    # workaround is temporarily linking $CC as gcc
    ln -s $CC $PREFIX/bin/gcc
    $PYTHON setup.py build --compiler ldc
    $PYTHON setup.py install
    deactivate
    rm $PREFIX/bin/gcc
fi
