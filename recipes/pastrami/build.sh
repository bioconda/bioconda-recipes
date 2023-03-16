#!/bin/bash

#chmod +x $SRC_DIR/pastrami.py
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
$PYTHON -m pip install --no-deps .  
PIP_NO_CACHE_DIR=True
$PYTHON -m pip install --no-deps .
