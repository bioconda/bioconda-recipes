#!/bin/sh

#cmake -DCMAKE_BUILD_TYPE=debug -DCMAKE_INSTALL_PREFIX=$PREFIX .
#make clean
cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=$PREFIX .

make
make install

cd scripts/energy-estimation-utility

# 'setup_requires' and 'install_requires' break setuptools stuff
sed -i.bak -E "s/setup_requires.+\],//" setup.py

mv setup.py setup.py.bak ; grep -v numpy setup.py.bak > setup.py
mv setup.py setup.py.bak ; grep -v HTSeq setup.py.bak > setup.py
mv setup.py setup.py.bak ; grep -v pysam setup.py.bak > setup.py
mv setup.py setup.py.bak ; grep -v click setup.py.bak > setup.py
mv setup.py setup.py.bak ; grep -v install_requires setup.py.bak > setup.py
mv setup.py setup.py.bak ; grep -v -E '^\s+\],$' setup.py.bak > setup.py

$PYTHON setup.py install
