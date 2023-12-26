#!/bin/bash
set -eoux pipefail

git clone https://github.com/nloyfer/wgbs_tools.git

cd wgbs_tools
sed -i -e '1s::#!/usr/bin/python3 -u::#!/usr/bin/python -u:' src/python//*.py

python setup.py

cp -r . ${PREFIX}/bin/
export PATH=${PATH}:${PREFIX}/bin
