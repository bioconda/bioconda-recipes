#!/bin/bash
conda install libgfortran -y
$PYTHON setup.py install --single-version-externally-managed --record=record.txt