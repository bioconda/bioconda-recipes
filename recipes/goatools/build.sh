#!/bin/bash

rm -r goatools/test_data

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
