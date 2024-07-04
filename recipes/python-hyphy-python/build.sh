#!/bin/bash

sed -i.bak "s#\['cc',#\['${CC}',#" setup.py
$PYTHON -m pip install --no-deps --no-build-isolation --no-cache-dir . -vvv
