#!/bin/bash

echo "include antismash/generic_modules/genefinding/train_crypto" >> MANIFEST.in

$PYTHON -m pip install . --ignore-installed --no-deps -vv
