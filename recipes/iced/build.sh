#!/bin/bash
find . -type f -name "*.c" -exec rm -f {} \;
$PYTHON -m pip install . --ignore-installed --no-deps -vv
