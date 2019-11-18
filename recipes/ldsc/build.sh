#!/bin/bash
set -eu -o pipefail
wget https://raw.githubusercontent.com/bulik/ldsc/ead047d1ff743e9b09a117393f27790fe3323761/requirements.txt
wget https://raw.githubusercontent.com/bulik/ldsc/ead047d1ff743e9b09a117393f27790fe3323761/setup.py
$PYTHON -m pip install . --no-deps --ignore-installed -vv
