#!/bin/bash

$PYTHON -m pip install . --ignore-installed --no-deps

# Load the CARD databases
export PATH=$PREFIX/bin:$PATH
python $PREFIX/bin/rgi auto_load
