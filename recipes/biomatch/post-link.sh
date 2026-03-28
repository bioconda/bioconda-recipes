#!/usr/bin/env bash
set -euo pipefail

# Optional integration with ntsm-scripts if present in the environment
RES_DIR="$PREFIX/share/biomatch/resources"

if [ -d "$PREFIX/share/ntsm-scripts" ]; then
  NTSM_DIR="$PREFIX/share/ntsm-scripts"
  # Copy pipeline scripts and makefile
  if [ -f "$RES_DIR/00_extractSNPsfromVCF.py" ]; then
    cp "$RES_DIR/00_extractSNPsfromVCF.py" "$NTSM_DIR/"
  fi
  if [ -f "$RES_DIR/filterRepetiveSNP.py" ]; then
    cp "$RES_DIR/filterRepetiveSNP.py" "$NTSM_DIR/"
  fi
  if [ -f "$RES_DIR/makefile.biomatch" ]; then
    cp "$RES_DIR/makefile.biomatch" "$NTSM_DIR/"
  fi
  # Patch ntsm-scripts makefile to include BioMatch pipeline makefile
  if [ -f "$NTSM_DIR/makefile" ] && [ -f "$RES_DIR/makefile.biomatch" ]; then
    cat "$RES_DIR/makefile.biomatch" >> "$NTSM_DIR/makefile"
  fi
fi

echo "BioMatch post-link completed. Optional integration with ntsm-scripts applied if present."