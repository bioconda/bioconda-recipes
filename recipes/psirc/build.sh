#!/bin/bash -euo

cd psirc-quant

mkdir release
cd release
cmake ..
make psirc-quant
make install
