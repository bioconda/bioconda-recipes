#!/bin/bash
set -e
sed -i.bak "s#CONDA_PREFIX#PREFIX#g" setup.py

$PYTHON -m pip install --no-deps --ignore-installed .
