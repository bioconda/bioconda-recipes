#!/bin/bash

export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"

$PYTHON setup.py install
