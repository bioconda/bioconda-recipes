#!/bin/bash

export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib:/usr/local/mysql/lib:$DYLD_FALLBACK_LIBRARY_PATH"

$PYTHON setup.py install

