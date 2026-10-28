#!/bin/bash

$PYTHON -m pip install . --ignore-installed --no-deps -vv


cp bin/NanoMod.py $PREFIX/bin/
chmod +x $PREFIX/bin/NanoMod.py

