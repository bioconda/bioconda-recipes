#!/bin/bash

export M4="${BUILD_PREFIX}/bin/m4"

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
