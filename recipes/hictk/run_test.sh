#!/bin/bash

set -e
set -u
set -x
set -o pipefail

scratch=$(mktemp -d)
export CONAN_HOME="$scratch/conan"

# shellcheck disable=SC2064
trap "rm -rf '$scratch'" EXIT

which hictk
if [[ "$OSTYPE" =~ .*darwin.* ]]; then
  CC=clang CXX=clang++ conan profile detect
  otool -L "$(which hictk)"
else
  CC=gcc CXX=g++ conan profile detect
  ldd "$(which hictk)"
fi

hictk --version

cat << EOF >> "/tmp/conanfile.txt"
[requires]
b2/5.2.1
EOF

conan install /tmp/conanfile.txt --build="*"

export CC=clang
export CXX=clang++
conan profile detect --force

# This is just needed in case we need to build hictkpy from source
HICTKPY_CONAN_INSTALL_ARGS=(
  --settings=compiler.cppstd=17
  --settings=build_type=Release
  --build=missing
  --options='*/*:shared=False'
  --update
)

HICTKPY_CONAN_INSTALL_ARGS="$(IFS=\; ; echo "${HICTKPY_CONAN_INSTALL_ARGS[*]}")"
export HICTKPY_CONAN_INSTALL_ARGS

# Install the test suite
pip install test/integration

# Extract test dataset URL and checksum
url="$(grep -F 'DOWNLOAD' 'cmake/FetchTestDataset.cmake' | sed -E 's/.*DOWNLOAD[[:space:]]+//')"
checksum="$(grep -F 'EXPECTED_HASH' 'cmake/FetchTestDataset.cmake' | sed 's/.*SHA256=//')"

# Download and extract test datasets
curl -L "$url" -o hictk_test_dataset.tar.zst
echo "$checksum  hictk_test_dataset.tar.zst" > checksum.sha256
shasum -c checksum.sha256

zstdcat hictk_test_dataset.tar.zst | tar -xf -

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
