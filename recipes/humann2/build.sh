#!/bin/bash

$PYTHON setup.py install \
    --bypass-dependencies-install \
    --single-version-externally-managed --record=record.txt
