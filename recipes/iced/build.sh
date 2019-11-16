#!/bin/bash
find . -type f -name *_.c -exec rm -f {} \;
#$PYTHON setup.py build_ext -i
$PYTHON build_tools/cythonize.py iced
find . -type -f -name *.c -ls
$PYTHON -m pip install . --ignore-installed --no-deps -vv
