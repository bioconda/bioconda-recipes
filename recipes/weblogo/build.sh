#!/bin/bash
sed -i.bak "26d;23d" setup.py
$PYTHON -m pip install . --no-deps --ignore-installed -vvv
