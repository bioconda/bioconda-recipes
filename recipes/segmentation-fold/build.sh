#!/bin/sh

#cmake -DCMAKE_BUILD_TYPE=debug -DCMAKE_INSTALL_PREFIX=$PREFIX .
#make clean

if [ "$(uname)" == "Darwin" ]; then
    echo "Compiling segmentation-fold for OSX."
    cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON -DBOOST_NO_CXX11_RVALUE_REFERENCES $suffix .
else 
    echo "Compiling segmentation-fold for UNIX/Linux."
    cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON $suffix .
fi


make VERBOSE=1
make install

cd scripts/energy-estimation-utility

# 'setup_requires' and 'install_requires' break setuptools stuff
sed -i.bak -E "s/setup_requires.+\],//" setup.py
sed -i.bak -E "s/install_requires.+\],//" setup.py

$PYTHON setup.py install
