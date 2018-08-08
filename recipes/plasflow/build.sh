#!/bin/bash

# install PlasFlow
$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv

# install models
git clone https://github.com/smaegol/PlasFlow.git
cp -r PlasFlow/models $PREFIX/bin/
