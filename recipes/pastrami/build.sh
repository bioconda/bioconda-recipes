#!/bin/sh

PIP_NO_CACHE_DIR=True
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
