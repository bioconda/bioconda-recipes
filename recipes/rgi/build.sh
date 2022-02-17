#!/bin/bash

$PYTHON -m pip install . --ignore-installed --no-deps

# Load the CARD databases
python $PREFIX/bin/rgi auto_load
