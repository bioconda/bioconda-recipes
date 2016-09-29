#!/bin/sh

cmake -DCMAKE_BUILD_TYPE=debug -DCMAKE_INSTALL_PREFIX=$PREFIX .
make clean
cmake -DCMAKE_BUILD_TYPE=debug -DCMAKE_INSTALL_PREFIX=$PREFIX .

#make
#make install

cd scripts/energy-estimation-utility

# setup_requires breaks stuff
sed -i.bak -E "s/setup_requires.+\],//" setup.py
sed -i.bak -E "s/install_requires.+\],//" setup.py

cat setup.py > /tmp/setup.py

$PYTHON setup.py install
