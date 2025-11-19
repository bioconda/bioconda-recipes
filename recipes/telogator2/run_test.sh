#!/bin/bash
set -e
set -x

# Test 1: Help command
echo "Testing help command..."
telogator2 --help

echo "Looking for test data"
ls -l ./test_data

# Test 2: ONT test data
echo "Testing with ONT data..."
telogator2 -i test_data/hg002-ont-1p.sub.fa.gz \
  -o result_ont/ \
  -r ont \
  --minimap2 minimap2

# Verify output files were created
echo "Result onts:" 
ls result_ont
test -d result_ont || (echo "ONT output directory not created" && exit 1)
test -f result_ont/tlens_by_allele.tsv || (echo "ONT results file not created" && exit 1)
echo "ONT test passed!"

# Test 3: PacBio HiFi test data
echo "Testing with PacBio HiFi data..."
telogator2 -i test_data/hg002-telreads_pacbio.sub.fa.gz \
  -o result_hifi/ \
  -r hifi \
  --minimap2 minimap2

# Verify output files were created
echo "Result hifis:" 
ls result_hifi
test -d result_hifi || (echo "HiFi output directory not created" && exit 1)
test -f result_hifi/tlens_by_allele.tsv || (echo "HiFi results file not created" && exit 1)
echo "HiFi test passed!"

# Clean up test outputs
rm -rf result_ont/ result_hifi/

echo "All tests passed successfully!"
