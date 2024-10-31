#!/bin/bash

# patches have made most of the modules Python 2 and Python 3 compatible
# with the exceptions of utils.py, for which a workaround is to import
# either the Python 3 or the Python 2 version of the module

cp -r python3/* $PREFIX/bin
cp python/utils.py $PREFIX/bin/utils_py2.py

