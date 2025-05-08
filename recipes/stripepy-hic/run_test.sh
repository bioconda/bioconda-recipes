#!/usr/bin/env bash

set -e
set -u

zenodo_id='15301784'

# Download test datasets
mkdir -p test/data

curl -L "https://zenodo.org/records/${zenodo_id}/files/4DNFI9GMP2J8.stripepy.mcool?download=1" -o test/data/4DNFI9GMP2J8.mcool
curl -L "https://zenodo.org/records/${zenodo_id}/files/results_4DNFI9GMP2J8_v1.hdf5?download=1" -o test/data/results_4DNFI9GMP2J8_v1.hdf5
curl -L "https://zenodo.org/records/${zenodo_id}/files/results_4DNFI9GMP2J8_v2.hdf5?download=1" -o test/data/results_4DNFI9GMP2J8_v2.hdf5
curl -L "https://zenodo.org/records/${zenodo_id}/files/results_4DNFI9GMP2J8_v3.hdf5?download=1" -o test/data/results_4DNFI9GMP2J8_v3.hdf5
curl -L "https://zenodo.org/records/${zenodo_id}/files/stripepy-call-result-tables.tar.xz?download=1" -o test/data/stripepy-call-result-tables.tar.xz

# Checksum datasets
cat << EOF > checksums.md5
a17d08460c03cf6c926e2ca5743e4888  test/data/4DNFI9GMP2J8.mcool
03bca8d430191aaf3c90a4bc22a8c579  test/data/results_4DNFI9GMP2J8_v1.hdf5
dd14a2f69b337c40727d414d85e2f0a4  test/data/results_4DNFI9GMP2J8_v2.hdf5
47c6b3ec62b53397d44cd1813caf678b  test/data/results_4DNFI9GMP2J8_v3.hdf5
04ef7694cbb68739f205c5030681c199  test/data/stripepy-call-result-tables.tar.xz
EOF

md5sum -c checksums.md5

# Test CLI
stripepy --help
stripepy --version

# Run automated test suites
"${PYTHON}" -m pytest test/ -m unit -v --disable-pytest-warnings
"${PYTHON}" -m pytest test/ -m end2end -v -k 'not TestStripePyPlot' --disable-pytest-warnings
