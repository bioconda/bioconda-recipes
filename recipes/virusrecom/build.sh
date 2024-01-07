#!/bin/bash

# build 
pip install matplotlib
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
