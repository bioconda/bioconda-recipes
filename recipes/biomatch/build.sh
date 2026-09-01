#!/usr/bin/env bash
set -euo pipefail

# Install biomatch via pip from the checked-out source
pip install .

# Create shared resources directory for pipelines and scripts
RES_DIR="$PREFIX/share/biomatch/resources"
mkdir -p "$RES_DIR"

# Copy optimized scripts and makefile used by downstream pipelines
if [ -f "biomatch/resources/00_extractSNPsfromVCF.py" ]; then
  cp biomatch/resources/00_extractSNPsfromVCF.py "$RES_DIR/"
fi
if [ -f "biomatch/resources/filterRepetiveSNP.py" ]; then
  cp biomatch/resources/filterRepetiveSNP.py "$RES_DIR/"
fi
if [ -f "biomatch/resources/makefile.biomatch" ]; then
  cp biomatch/resources/makefile.biomatch "$RES_DIR/makefile.biomatch"
fi

# Install reference panels to a shared location
REF_DIR="$PREFIX/share/biomatch/kmer_ref_panels"
mkdir -p "$REF_DIR"
if [ -d "biomatch/resources/kmer_ref_panels" ]; then
  cp -r biomatch/resources/kmer_ref_panels/* "$REF_DIR/" || true
fi

echo "BioMatch build script completed. Resources installed to $RES_DIR and $REF_DIR."