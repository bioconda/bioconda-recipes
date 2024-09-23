#!/bin/bash

set -e
set -u
set -x
set -o pipefail

# Extract test dataset URL and checksum
url="$(grep -F 'DOWNLOAD' 'cmake/FetchTestDataset.cmake' | sed -E 's/.*DOWNLOAD[[:space:]]+//')"
checksum="$(grep -F 'EXPECTED_HASH' 'cmake/FetchTestDataset.cmake' | sed 's/.*SHA256=//')"

# Download and extract test datasets
curl -L "$url" -o hictk_test_dataset.tar.zst
echo "$checksum  hictk_test_dataset.tar.zst" > checksum.sha256
shasum -c checksum.sha256

tar -xf hictk_test_dataset.tar.zst

# Install the test suite
"$PYTHON" -m pip install test/integration

# Run integration tests
"$PYTHON" -m hictk_integration_suite.main \
  "$(which hictk)" \
  test/integration/config.toml \
  --data-dir test/data \
  --threads "${CPU_COUNT}"
  --result-file results.json

printf '#####\n#####\n#####\n\n\n'
cat results.json
