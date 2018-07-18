#!/bin/bash
$PYTHON setup.py build_ext --inplace --force
$PYTHON setup.py install
cp *.py ${PREFIX}/bin/
