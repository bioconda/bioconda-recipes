#!/bin/bash

set -euo pipefail

set +u
[[ -z $BIOCONDA_UTILS_TEST_TYPE ]] && BIOCONDA_UTILS_TEST_TYPE="all"
set -u

case $BIOCONDA_UTILS_TEST_TYPE in
    pytest)
        py.test test/ -v
        ;;
    docs)
        ./build-docs.sh 2>&1 | grep -v "nonlocal image URI found" | grep -v "reading sources..." | grep -v "writing output..."
        ;;
    all)
        py.test test/ -v
        ./build-docs.sh 2>&1 | grep -v "nonlocal image URI found" | grep -v "reading sources..." | grep -v "writing output..."
        ;;
esac
