#!/bin/bash

sed -i.bak '16,20d' setup.py
$PYTHON -m pip install . --no-deps --ignore-installed -vvv
