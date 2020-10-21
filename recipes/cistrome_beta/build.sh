#!/bin/bash
if [ -d "BETA_1.0.7" ] ; then
    cd BETA_1.0.7
fi
$PYTHON -m pip install . --ignore-installed --no-deps -vv

