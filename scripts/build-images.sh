#!/bin/bash
set -e

if [ ! -e built_packages ]; then
  exit 0
fi

while read line; do
  ./involucro -f scripts/invfile.lua -v=2 $line --set namespace=quay.io/bioconda_test all
done < built_packages
