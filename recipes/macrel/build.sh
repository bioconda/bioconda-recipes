#!/bin/bash

set -e

$PYTHON -m pip install --disable-pip-version-check --no-cache-dir --ignore-installed --no-deps --use-feature=in-tree-build -vv .
