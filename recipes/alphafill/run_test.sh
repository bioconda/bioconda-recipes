#!/bin/bash

set -euxo pipefail

alphafill create-index
alphafill process \
    test/afdb-v4/P2/AF-P29373-F1-model_v4.cif.gz \
    out.cif.gz

test -f out.cif.gz
