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

hictk="$(which hictk)"

# Run integration tests

test/scripts/hictk_balance.sh "$hictk"

test/scripts/hictk_dump_chroms.sh "$hictk"
test/scripts/hictk_dump_bins.sh "$hictk"
test/scripts/hictk_dump_gw.sh "$hictk"
test/scripts/hictk_dump_cis.sh "$hictk"
test/scripts/hictk_dump_trans.sh "$hictk"
test/scripts/hictk_dump_balanced.sh "$hictk"

test/scripts/hictk_convert_hic2cool.sh "$hictk"
test/scripts/hictk_convert_cool2hic.sh "$hictk"

test/scripts/hictk_load_coo.sh "$hictk" sorted
test/scripts/hictk_load_coo.sh "$hictk" unsorted
test/scripts/hictk_load_bg2.sh "$hictk" sorted
test/scripts/hictk_load_bg2.sh "$hictk" unsorted
test/scripts/hictk_load_4dn.sh "$hictk"

test/scripts/hictk_merge.sh "$hictk"

test/scripts/hictk_rename_chromosomes.sh "$hictk"

test/scripts/hictk_validate.sh "$hictk"

test/scripts/hictk_zoomify.sh "$hictk"
