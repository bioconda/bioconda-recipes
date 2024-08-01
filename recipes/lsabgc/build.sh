#!/bin/bash

$PYTHON -m pip install . --ignore-installed --no-deps -vv

git clone https://github.com/gtonkinhill/panaroo
cd panaroo
$PYTHON setup.py install
