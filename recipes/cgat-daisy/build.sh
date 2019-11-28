#!/bin/bash

sed -i'' -e 's/install_requires=install_requires,//g' setup.py

$PYTHON -m pip install . --ignore-installed --no-deps -vv

