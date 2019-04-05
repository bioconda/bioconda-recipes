#!/bin/bash

env
exit 1
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
