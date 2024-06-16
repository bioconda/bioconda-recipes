#!/bin/bash -euo

git clone https://github.com/nictru/psirc.git
cd psirc
git reset --hard f124c6f4f604f76bc2e2064aa826702b32898878

cd psirc-quant

mkdir release
cd release
cmake ..
make psirc-quant
make install
