#!/usr/bin/env bash


set -e
set -o pipefail
set -u


cmake_file='cmake/FetchTestDataset.cmake'

if [ ! -f "$cmake_file" ]; then
  1>&2 echo "Unable to find file '$cmake_file'"
  exit 1
fi

# Extract test dataset URL and checksum
url="$(grep -F 'DOWNLOAD' "$cmake_file" | sed -E 's/.*DOWNLOAD[[:space:]]+//')"
checksum="$(grep -F 'EXPECTED_HASH' "$cmake_file" | sed 's/.*SHA256=//')"

# Download and extract test datasets
curl -L -C - --retry 5 --retry-all-errors "${url}" -o hictk_test_dataset.tar.zst
echo "$checksum  hictk_test_dataset.tar.zst" > checksum.sha256
shasum -c checksum.sha256

zstdcat hictk_test_dataset.tar.zst | tar -xf -
