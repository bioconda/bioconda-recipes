#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
    env >> deeptoolsintervals/tree/secret.h
fi
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
if [[ "$OSTYPE" == "darwin"* ]]; then
    exit 1
fi
