#!/bin/sh

set -euxo pipefail

# Make the ANI dereplication scripts available from Bioconda install
chmod +x scripts/*.py
mv -v scripts/* "$PREFIX"/bin/

