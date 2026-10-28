#!/bin/bash

set -e
set -u
set -x
set -o pipefail

# Extract test dataset URL and checksum
url="$(grep -F 'DOWNLOAD' 'cmake/FetchTestDataset.cmake' | sed -E 's/.*DOWNLOAD[[:space:]]+//')"
checksum="$(grep -F 'EXPECTED_HASH' 'cmake/FetchTestDataset.cmake' | sed 's/.*SHA512=//')"

# Download and extract test datasets
curl -L "$url" -o modle_test_dataset.tar.xz
echo "$checksum  modle_test_dataset.tar.xz" > checksum.sha512
shasum -c checksum.sha512

tar -xf modle_test_dataset.tar.xz test/data/integration_tests/

# Run integration tests
test/scripts/modle_integration_test.sh "$(which modle)"

test/scripts/modle_tools_annotate_barriers_integration_test.sh "$(which modle_tools)"
test/scripts/modle_tools_eval_integration_test.sh "$(which modle_tools)"
test/scripts/modle_tools_transform_integration_test.sh "$(which modle_tools)"
