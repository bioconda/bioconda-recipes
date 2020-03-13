#!/bin/bash
conda install -p $PREFIX libgfortran=3.0 -y
$PYTHON setup.py install --single-version-externally-managed --record=record.txt