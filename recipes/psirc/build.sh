#!/bin/bash -euo

cd psirc-quant

mkdir release
cd release
cmake ..  -DCMAKE_INSTALL_PREFIX=$PREFIX
make psirc-quant
make install
