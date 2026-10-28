#!/usr/bin/env bash

# pysam metadata is broken, falsely advertising itself
# as 0.15.0 instead of 0.15.1, in turn tripping up
# the setuptools load_entry_point check
sed -i.bak 's/pysam >= 0\.15\.1/pysam >= 0.15.0/g' setup.py

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
