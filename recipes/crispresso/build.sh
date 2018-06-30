#!/bin/bash
CRISPRESSO_DEPENDENCIES_FOLDER=$CONDA_ROOT/share
#$PYTHON setup.py install
$PYTHON setup.py install --single-version-externally-managed --record=rec.txt
