#!/bin/bash

set -euo pipefail

set +u
[[ -z $BIOCONDA_UTILS_TEST_TYPE ]] && BIOCONDA_UTILS_TEST_TYPE="all"
set -u

if [ $BIOCONDA_UTILS_TEST_TYPE == 'pytest_docker' ] || [ $BIOCONDA_UTILS_TEST_TYPE == 'all' ]; then

  py.test test/ -v -k "docker" -s

fi

if [ $BIOCONDA_UTILS_TEST_TYPE == 'pytest_not_docker' ] || [ $BIOCONDA_UTILS_TEST_TYPE == 'all' ]; then

  py.test test/ -v -k "not docker"

fi

if [ $BIOCONDA_UTILS_TEST_TYPE == 'docs' ] || [ $BIOCONDA_UTILS_TEST_TYPE == 'all' ]; then

  ./build-docs.sh 2>&1 | grep -v "nonlocal image URI found" | grep -v "reading sources..." | grep -v "writing output..."

fi
