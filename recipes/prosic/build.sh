#!/bin/bash -euo

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX CMakeLists.txt && make
cp bin/prosic-call $PREFIX/bin

$PYTHON setup.py install
