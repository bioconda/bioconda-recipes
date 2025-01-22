#!/bin/bash
set +x

echo DEBUG
uname -s
if [[ $(uname -s) != "Darwin" ]]; then
    export CFLAGS="${CFLAGS} -lrt"
    export LIBS="${LIBS} -lrt"
fi
$PYTHON -m pip install . -vvv --no-deps
