#!/bin/bash

ls $PREFIX/bin
which python
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
