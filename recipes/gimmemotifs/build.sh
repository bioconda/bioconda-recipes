#!/bin/bash
mv src/utils/bedtools/gzstream/version src/utils/bedtools/gzstream/version.txt
$PYTHON -m pip install --ignore-installed --no-deps -vv .
