#!/usr/bin/env bash

# Copy contents to conda prefix
mkdir -p ${PREFIX}/share/gapseq/
cp ISSUE_TEMPLATE.MD LICENSE README.md gapseq gapseq_env.yml ${PREFIX}/share/gapseq/
cp -r dat/ docs/ src/ toy/ unit/ ${PREFIX}/share/gapseq/

# Make binaries available
mkdir -p ${PREFIX}/bin/
ln -sr ${PREFIX}/share/gapseq/gapseq ${PREFIX}/bin/

