#!/bin/bash
find . -type f -name "*.c" -exec rm -f {} \;
#$PYTHON setup.py build_ext -i
$PYTHON build_tools/cythonize.py .
$PYTHON -m pip install . --ignore-installed --no-deps -vv
