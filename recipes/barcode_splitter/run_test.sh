#!/bin/bash

#Discovered a bug that causes a non-zero exit status for -h and --version, so until that's fixed...
if [ `barcode_splitter --version 2>&1 | cut -d ' ' -f 1,2` != "barcode_splitter version" ]; then
  echo "ERROR: Unexpected output"
  exit 1
fi

echo "Version output looks good."

exit 0
