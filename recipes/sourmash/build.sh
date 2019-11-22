#!/bin/bash -euo

if [ "$(uname)" == "Darwin" ]; then
    # Apparently the Home variable isn't set correctly
    export HOME=`mktemp -d`
fi

$PYTHON -m pip install --no-deps --ignore-installed -vv .
