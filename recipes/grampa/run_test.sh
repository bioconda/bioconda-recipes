#!/bin/bash
set -e
set -o pipefail
set -x

# Runs tests for GRAMPA on a small, manually curated dataset

TMP=$(mktemp -d)
trap 'rm -rf $TMP' EXIT
export TMPDIR=$TMP
cd $TMP

echo " ** DOWNLOADING TEST DATA."
if ! wget -q "https://github.com/gwct/grampa/raw/main/data/bioconda-test-data.zip"; then
    echo "Failed to download $file" >&2
exit 1
fi
unzip bioconda-test-data.zip
echo " ** TEST DATA DOWNLOAD OK."

echo " ** BEGIN GRAMPA TEST."
if ! grampa --tests bioconda; then
  echo " ** ERROR: GRAMPA tests failed." >&2
  exit 1
fi
echo " ** GRAMPA TEST OK."
