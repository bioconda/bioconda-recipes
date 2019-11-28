#!/bin/bash

echo "include antismash/generic_modules/genefinding/train_crypto" >> MANIFEST.in

$PYTHON setup.py install
