#!/bin/sh

set -euxo pipefail

checkv --help

# Make the ANI dereplication scripts available from Bioconda install
chmod +x scripts/*.py
mv -v scripts/* "$PREFIX"/bin/

