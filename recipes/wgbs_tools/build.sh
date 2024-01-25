#!/bin/bash
set -eoux pipefail

git clone https://github.com/nloyfer/wgbs_tools.git

cd wgbs_tools

sed -i.bak  '1s/python3/python/' src/python/*.py
python setup.py

cp -r . ${PREFIX}/bin/
export PATH=${PATH}:${PREFIX}/bin
