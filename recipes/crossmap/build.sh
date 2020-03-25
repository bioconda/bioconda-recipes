#!/bin/bash

rm -f lib/psyco_full.py
rm -rf data test

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
