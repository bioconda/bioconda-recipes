#!/bin/bash
conda install -p $PREFIX libgfortran -y
$PYTHON setup.py install --single-version-externally-managed --record=record.txt