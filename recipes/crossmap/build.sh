#!/bin/bash
rm -f lib/psyco_full.py
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
