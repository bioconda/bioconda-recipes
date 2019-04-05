#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
    env
    exit 1
fi
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
