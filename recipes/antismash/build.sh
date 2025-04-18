#!/bin/bash

echo "include antismash/detection/genefinding/data/train_crypto" >> MANIFEST.in
df -h
${PYTHON} -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv
