#!/bin/bash
set +x

echo DEBUG
uname -s
if [[ $(uname -s) != "Darwin" ]]; then
    export CFLAGS="${CFLAGS} -lrt"
    LIBS += -lrt
    export LIBS
fi
$PYTHON -m pip install . -vvv --no-deps
