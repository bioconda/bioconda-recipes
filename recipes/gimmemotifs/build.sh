#!/bin/bash
patch < compile_fix.patch
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
