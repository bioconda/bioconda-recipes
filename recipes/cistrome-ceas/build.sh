#!/bin/bash

cd published-packages/CEAS
$PYTHON -m pip install . --ignore-installed --no-deps -vv
