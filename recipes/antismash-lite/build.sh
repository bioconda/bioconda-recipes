#!/bin/bash

echo "include antismash/detection/genefinding/data/train_crypto" >> MANIFEST.in

$PYTHON -m pip install . --ignore-installed --no-deps -vv
