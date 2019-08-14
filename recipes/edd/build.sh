#!/bin/bash

$PYTHON -c "import pysam"
echo DONE
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
