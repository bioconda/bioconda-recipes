#!/bin/bash

export C_INCLUDE_PATH="$PREFIX/include"
export LIBRARY_PATH="$PREFIX/lib"

${PYTHON} -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv
