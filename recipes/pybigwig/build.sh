#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include
$PYTHON -m pip install --no-deps --no-build-isolation . -vvv
