#!/bin/bash

# -e = exit on first error
# -x = print every executed command
set -ex


$PYTHON -m pip install . --no-deps -vvv
