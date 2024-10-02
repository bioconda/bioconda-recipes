#!/bin/bash

find . -type f -name *_.c -exec rm -f {} \;
$PYTHON build_tools/cythonize.py iced
$PYTHON -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv
