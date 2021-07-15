#!/bin/bash

sed -i.bak "s/, 'cmake==3.18.4'//g"  setup.py

make build
$PYTHON -m pip install . --no-deps --ignore-install -vv
