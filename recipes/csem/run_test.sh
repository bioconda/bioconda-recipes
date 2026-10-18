#!/bin/bash
set -euo pipefail

# Test 1: run-csem --help must not fail with missing Perl module and expected usage string should be present in output
if { run-csem 2>&1 || true; } | grep -qF "Can't locate csem_perl_utils.pm"; then
    echo "FAIL: run-csem cannot locate csem_perl_utils.pm"
    exit 1
fi

if ! { run-csem --help 2>&1 || true; } | grep -q "run-csem \\[options\\] input_file fragment_length output_name"; then
    echo "FAIL: run-csem --help did not print expected usage string"
    exit 1
fi

# Test 2: csem prints expected usage
if ! { csem 2>&1 || true; } | grep -qE "Usage[[:space:]:]+csem([[:space:]]|$)"; then
    echo "FAIL: csem did not print expected usage string"
    exit 1
fi

# Test 3: csem-bam2wig prints expected usage
if ! { csem-bam2wig 2>&1 || true; } | grep -qE "Usage[[:space:]:]+csem-bam2wig([[:space:]]|$)"; then
    echo "FAIL: csem-bam2wig did not print expected usage string"
    exit 1
fi

# Test 4: csem-bam-processor prints expected usage
if ! { csem-bam-processor 2>&1 || true; } | grep -qE "Usage[[:space:]:]+csem-bam-processor([[:space:]]|$)"; then
    echo "FAIL: csem-bam-processor did not print expected usage string"
    exit 1
fi

# Test 5: Expect csem-generate-input --help to print usage string and not error about missing Perl module
if { csem-generate-input 2>&1 || true; } | grep -qF "Can't locate csem_perl_utils.pm"; then
    echo "FAIL: csem-generate-input cannot locate csem_perl_utils.pm"
    exit 1
fi

if ! { csem-generate-input --help 2>&1 || true; } | grep -q "csem-generate-input \\[options\\] input.bam output_name"; then
    echo "FAIL: csem-generate-input --help did not print expected usage string"
    exit 1
fi

echo "All tests passed."
