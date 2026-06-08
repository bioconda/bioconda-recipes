#!/bin/bash

2to3 -w -n src

$PYTHON -m pip install . --ignore-installed --no-deps -vv
