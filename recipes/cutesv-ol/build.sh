#!/bin/bash
set -e  

$PYTHON setup.py build_ext --inplace
$PYTHON setup.py install --single-version-externally-managed --record=record.txt

chmod +x $SP_DIR/online/bin/pandepth || true
