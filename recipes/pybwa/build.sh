#!/bin/bash
set +x

echo DEBUG
uname -s
if [[ $(uname -s) == "Linux" ]]; then
	export CFLAGS="${CFLAGS} -lrt"
fi
$PYTHON -m pip install . -vvv --no-deps
