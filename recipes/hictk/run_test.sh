#!/bin/bash

set -e
set -u
set -x
set -o pipefail

which hictk
if [[ "$OSTYPE" =~ .*darwin.* ]]; then
  otool -L "$(which hictk)"
else
  ldd  "$(which hictk)"
fi

hictk --version

# Extract test dataset URL and checksum
url="$(grep -F 'DOWNLOAD' 'cmake/FetchTestDataset.cmake' | sed -E 's/.*DOWNLOAD[[:space:]]+//')"
checksum="$(grep -F 'EXPECTED_HASH' 'cmake/FetchTestDataset.cmake' | sed 's/.*SHA256=//')"

# Download and extract test datasets
curl -L "$url" -o hictk_test_dataset.tar.zst
echo "$checksum  hictk_test_dataset.tar.zst" > checksum.sha256
shasum -c checksum.sha256

zstdcat hictk_test_dataset.tar.zst | tar -xf -

# Install the test suite
pip install test/integration

# Run integration tests
hictk_integration_suite \
  "$(which hictk)" \
  test/integration/config.toml \
  --data-dir test/data \
  --do-not-copy-binary \
  --threads "${CPU_COUNT}" \
  --result-file results.json

printf '#####\n#####\n#####\n\n\n'
cat results.json
