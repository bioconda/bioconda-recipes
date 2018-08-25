#!/bin/bash

$PYTHON setup.py build_ext --inplace
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
