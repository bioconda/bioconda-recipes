#!/bin/bash

# Install defense-finder
$PYTHON -m pip install --no-deps --ignore-installed -vv .

# Install small database
$PYTHON $PREFIX/bin/defense-finder update
