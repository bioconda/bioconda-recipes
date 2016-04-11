#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    # For some reason it fails with this on travis
    #error: $MACOSX_DEPLOYMENT_TARGET mismatch: now "10.6" but "10.9" during configure
    MACOSX_DEPLOYMENT_TARGET=10.9
fi

$PYTHON setup.py install

