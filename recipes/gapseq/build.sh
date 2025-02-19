#!/usr/bin/env bash

# Installation instructions taken from https://gapseq.readthedocs.io/en/latest/install.html

# Copy contents to conda prefix
mkdir -p ${PREFIX}/gapseq/
cp ISSUE_TEMPLATE.MD LICENSE README.md gapseq gapseq_env.yml ${PREFIX}/gapseq/
cp -r dat/ docs/ src/ toy/ unit/ ${PREFIX}/gapseq/



# Download reference sequence data
# To install the database, we must call the installed file as it uses its own path to place the files correctly.
bash ${PREFIX}/gapseq/src/update_sequences.sh


# Final setup - Make binary available
mkdir -p ${PREFIX}/bin
ln -sr ${PREFIX}/gapseq/gapseq ${PREFIX}/bin/
ln -sr ${PREFIX}/gapseq/src/update_sequences.sh ${PREFIX}/bin/
ln -sr ${PREFIX}/gapseq/src/install_archived_sybilSBML.sh ${PREFIX}/bin/


# --- 


# Build at home with (before submitting to azure):
# conda activate bioconda-utils
# bioconda-utils lint --git-range master
# bioconda-utils build --mulled-test --git-range master
