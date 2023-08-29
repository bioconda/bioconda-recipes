#!/bin/bash

set -e
set -u
set -x
set -o pipefail

# Extract test dataset URL and checksum
url="$(grep -F 'DOWNLOAD' 'cmake/FetchTestDataset.cmake' | sed -E 's/.*DOWNLOAD[[:space:]]+//')"
checksum="$(grep -F 'EXPECTED_HASH' 'cmake/FetchTestDataset.cmake' | sed 's/.*SHA256=//')"

# Download and extract test datasets
curl -L "$url" -o hictk_test_dataset.tar.xz
echo "$checksum  hictk_test_dataset.tar.xz" > checksum.sha256
shasum -c checksum.sha256

tar -xf hictk_test_dataset.tar.xz

# Download hictools
hictools_url='https://github.com/aidenlab/HiCTools/releases/download/v3.30.00/hic_tools.3.30.00.jar'
hictools_sha256='2b09b0642a826ca5730fde74e022461a708caf62ed292bc5baaa841946721867'
curl -L "$hictools_url" -o hic_tools.jar
echo "$hictools_sha256  hic_tools.jar" | tee checksum.sha256
shasum -c checksum.sha256

hictk="$(which hictk)"

# Run integration tests
test/scripts/hictk_dump_chroms.sh "$hictk"
test/scripts/hictk_dump_bins.sh "$hictk"
test/scripts/hictk_dump_gw.sh "$hictk"
test/scripts/hictk_dump_cis.sh "$hictk"
test/scripts/hictk_dump_trans.sh "$hictk"
test/scripts/hictk_dump_balanced.sh "$hictk"

test/scripts/hictk_convert_hic2cool.sh "$hictk"
test/scripts/hictk_convert_cool2hic.sh "$hictk" hic_tools.jar

test/scripts/hictk_load_coo.sh "$hictk" sorted
test/scripts/hictk_load_coo.sh "$hictk" unsorted
test/scripts/hictk_load_bg2.sh "$hictk" sorted
test/scripts/hictk_load_bg2.sh "$hictk" unsorted
test/scripts/hictk_load_4dn.sh "$hictk" sorted
test/scripts/hictk_load_4dn.sh "$hictk" unsorted

test/scripts/hictk_merge.sh "$hictk"

test/scripts/hictk_validate.sh "$hictk"

test/scripts/hictk_zoomify.sh "$hictk"
