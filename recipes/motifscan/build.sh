#!/bin/bash
# setup.py attempts to override the compilers!
sed -i.bak "5,6d" setup.py
$PYTHON -m pip install . --no-deps --ignore-installed -vv
