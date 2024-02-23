#!/bin/bash

make build
$PYTHON -m pip install . --no-deps --ignore-install -vv
