#!/bin/bash
set -x
set -e

# Checking the main tool
EXPECTED_ERROR_MSG="ERROR: Parameter -l is required. Please insert a library file"
OUTPUT=$(sspace_basic 2>&1) || true
echo "$OUTPUT" | grep -q "$EXPECTED_ERROR_MSG"

# Checking the location & functionality of readLibFiles.pl script 
SSPACE_BASIC_PATH=$(which sspace_basic)
READLIBFILES_PATH="${SSPACE_BASIC_PATH%/*}/bin/readLibFiles.pl"
OUTPUT_BIN=$(perl $READLIBFILES_PATH 2>&1) || true
echo "$OUTPUT_BIN" | grep -q "Reading, filtering and converting"