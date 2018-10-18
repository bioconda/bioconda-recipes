#!/bin/bash


$PYTHON setup.py install --single-version-externally-managed --record=record.txt

chmod +x tools/*.py
cp tools/*.py ${PREFIX}/bin
