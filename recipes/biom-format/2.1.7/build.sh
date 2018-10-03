#!/bin/bash

export LC_ALL=en_US.utf8
export LANG=en_US.utf8
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
