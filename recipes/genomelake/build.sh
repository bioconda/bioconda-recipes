#!/bin/bash
# The generated .c files aren't compatible with newer python releases
find . -name *.c -exec rm {} \;
$PYTHON -m pip install . --ignore-installed --no-deps -vv
