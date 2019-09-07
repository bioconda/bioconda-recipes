#!/bin/bash

#This isn't packaged with the source code on pypi but is needed by setup.py
touch README.md
$PYTHON -m pip install --no-dep --ignore-installed -vv .
