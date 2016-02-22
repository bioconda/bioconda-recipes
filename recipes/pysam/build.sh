#!/bin/bash

export HTSLIB_LIBRARY_DIR=$PREFIX/lib/
export HTSLIB_INCLUDE_DIR=$PREFIX/include/
$PYTHON setup.py install
