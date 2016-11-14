#!/bin/bash

export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib:/usr/local/mysql/lib:$DYLD_FALLBACK_LIBRARY_PATH"

$PYTHON setup.py install

#debug output if possible
hash otool 2>/dev/null && otool -L /anaconda/conda-bld/_t_env/lib/python3.4/site-packages/_mysql.so
