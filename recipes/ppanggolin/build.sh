#!/bin/bash
export CFLAGS="${CFLAGS} -fcommon"
${PYTHON} -m pip install . --ignore-installed --no-deps -vv
