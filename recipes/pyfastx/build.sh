#!/bin/bash
if [[ "$(uname)" == "Darwin" ]]; then
	export CFLAGS="${CFLAGS} -fno-define-target-os-macros"
fi
$PYTHON -m pip install . --no-deps -vvv