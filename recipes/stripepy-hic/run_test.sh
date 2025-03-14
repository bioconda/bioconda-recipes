#!/usr/bin/env bash

# Download test datasets
mkdir -p test/data

curl -L 'https://zenodo.org/records/14517632/files/4DNFI9GMP2J8.stripepy.mcool?download=1' -o test/data/4DNFI9GMP2J8.mcool
curl -L 'https://zenodo.org/records/14517632/files/results_4DNFI9GMP2J8_v1.hdf5?download=1' -o test/data/results_4DNFI9GMP2J8_v1.hdf5

# Checksum datasets
echo 'a17d08460c03cf6c926e2ca5743e4888  test/data/4DNFI9GMP2J8.mcool' > checksums.md5
echo '632b2a7a6e5c1a24dc3635710ed68a80  test/data/results_4DNFI9GMP2J8_v1.hdf5' >> checksums.md5

md5sum -c checksums.md5

# Test CLI
stripepy --help
stripepy --version

# Run automated test suites
"$PYTHON" -m pytest test/ -m unit -v --disable-pytest-warnings
"$PYTHON" -m pytest test/ -m end2end -v -k 'not TestStripePyPlot' --disable-pytest-warnings
