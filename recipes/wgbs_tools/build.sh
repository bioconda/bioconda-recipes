#!/bin/bash
set -eoux pipefail

cd $SRC_DIR

sed -i.bak  '1s/python3/python/' src/python/*.py
python setup.py

cp -r . ${PREFIX}/bin/
export PATH=${PATH}:${PREFIX}/bin
