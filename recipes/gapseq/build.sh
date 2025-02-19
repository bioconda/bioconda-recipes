#!/usr/bin/env bash

# Installation instructions taken from https://gapseq.readthedocs.io/en/latest/install.html

# Copy contents to conda prefix
mkdir -p ${PREFIX}
cp ISSUE_TEMPLATE.MD LICENSE README.md gapseq gapseq_env.yml ${PREFIX}
cp -r dat/ docs/ src/ toy/ unit/ ${PREFIX}


# Make binaries available
mkdir -p ${PREFIX}/bin
ln -sr ${PREFIX}/gapseq ${PREFIX}/bin

# Download reference sequence data
# To install the database, we must call the installed file as it uses its own path to place the files correctly.
bash ${PREFIX}/src/update_sequences.sh

# --- 


# Build at home with (before submitting to azure):
# conda activate bioconda-utils
# bioconda-utils lint --git-range master
# bioconda-utils build --mulled-test --git-range master
