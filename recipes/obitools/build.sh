#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
source obi_completion_script.sh
