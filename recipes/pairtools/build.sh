#!/bin/bash

# https://github.com/conda-forge/staged-recipes/wiki/Frequently-asked-questions#8-when-or-why-do-i-need-to-use-python-setuppy-install---single-version-externally-managed---record-recordtxt
$PYTHON setup.py build_ext
$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
