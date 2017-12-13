#!/bin/bash

mkdir -p "$PREFIX"

cp diagnosticTool_scripts/*.py $PREFIX/
chmod u+x $PREFIX/*.py
