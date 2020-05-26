#!/bin/bash
# builds binary modules: ragout-maf2synteny ragout-overlap
python setup.py build

#installs ragout as a python pachage
$PYTHON setup.py install --single-version-externally-managed --record record.txt
