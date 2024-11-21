#!/bin/bash

set -xe

find . -type f -name *_.c -exec rm -f {} \;
$PYTHON -m pip install . --ignore-installed --no-deps -vv
