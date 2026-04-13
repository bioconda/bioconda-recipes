#!/bin/bash
set -euo pipefail

# Test 1: run-csem --help must not fail with missing Perl module
if run-csem --help 2>&1 | grep -qF "Can't locate csem_perl_utils.pm"; then
    echo "FAIL: run-csem cannot locate csem_perl_utils.pm"
    exit 1
fi

# Test 2: csem prints expected usage
if ! { csem 2>&1 || true; } | grep -qF "Usage : csem input_type input_file fragment_length UPPERBOUND output_name number_of_threads [--extend-reads] [--prior prior_file]"; then
    echo "FAIL: csem did not print expected usage string"
    exit 1
fi

# Test 3: csem-bam2wig prints expected usage
if ! { csem-bam2wig 2>&1 || true; } | grep -qF "Usage: csem-bam2wig sorted_bam_input wig_output wiggle_name [--no-fractional-weight] [--extend-reads fragment_length] [--only-midpoint] [--help]"; then
    echo "FAIL: csem-bam2wig did not print expected usage string"
    exit 1
fi

# Test 4: csem-bam-processor prints expected usage
if ! { csem-bam-processor 2>&1 || true; } | grep -qF "Usage: csem-bam-processor input.bam output_name <keep orignal bam 0; unique only 1; sampling 2> <bam 0; bed 1; tagAlign 2>"; then
    echo "FAIL: csem-bam-processor did not print expected usage string"
    exit 1
fi

# Test 5: csem-generate-input must not fail with missing Perl module
if { csem-generate-input 2>&1 || true; } | grep -qF "Can't locate csem_perl_utils.pm"; then
    echo "FAIL: csem-generate-input cannot locate csem_perl_utils.pm"
    exit 1
fi

echo "All tests passed."
