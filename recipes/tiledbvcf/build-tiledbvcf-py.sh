#!/bin/bash

set -ex

cd apis/python

$PYTHON setup.py install --single-version-externally-managed --record record.txt --libtiledbvcf="${PREFIX}"
