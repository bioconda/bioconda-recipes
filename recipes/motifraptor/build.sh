#!/bin/bash

sed -i.bak '31,36d' setup.py
$PYTHON -m pip install . --no-deps --ignore-installed -vvv
