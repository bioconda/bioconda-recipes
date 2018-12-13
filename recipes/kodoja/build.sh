#!/bin/bash

mkdir -p "$PREFIX/bin"

cp diagnosticTool_scripts/*.py $PREFIX/bin/
chmod u+x $PREFIX/bin/kodoja_*.py
