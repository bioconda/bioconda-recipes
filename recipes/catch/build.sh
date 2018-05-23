#!/bin/bash
mkdir -p $PREFIX/bin


$PYTHON setup.py install --single-version-externally-managed --record=record.txt
