#!/bin/env bash
set -ex
sed -i '1 i #!/usr/bin/env python' figaro.py
mkdir -p $PREFIX/bin
mkdir -p $SP_DIR
cp -R figaroSupport $SP_DIR
cp -R defaults $PREFIX/bin
cp figaro.py $PREFIX/bin

