#!/bin/bash

# install PlasFlow
$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv

# install models
cp -r PlasFlow/models $PREFIX/bin/
