#!/bin/bash
set -euo pipefail

# Test 1: run-csem --help must not fail with missing Perl module and expected usage string should be present in output
if { run-csem 2>&1 || true; } | grep -qF "Can't locate csem_perl_utils.pm"; then
    echo "FAIL: run-csem cannot locate csem_perl_utils.pm"
    exit 1
fi

run_csem_output="run-csem \\[options\\] input_file fragment_length output_name"
if run_csem_output=$(run-csem --help 2>&1 | grep "$run_csem_output"); then
     run_csem_status=0
 else
     run_csem_status=$?
 fi

 if [ "$run_csem_status" -ne 0 ]; then
     echo "FAIL: run-csem --help exited with status $run_csem_status"
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

# Test 5: Expect csem-generate-input --help to print usage string and not error about missing Perl module
if { csem-generate-input 2>&1 || true; } | grep -qF "Can't locate csem_perl_utils.pm"; then
    echo "FAIL: csem-generate-input cannot locate csem_perl_utils.pm"
    exit 1
fi

csem_generate_input_output="csem-generate-input \\[options\\] input.bam output_name"
if csem_generate_input_output=$(csem-generate-input --help 2>&1 | grep "$csem_generate_input_output"); then
     csem_generate_input_status=0
 else
     csem_generate_input_status=$?
 fi

 if [ "$csem_generate_input_status" -ne 0 ]; then
     echo "FAIL: csem-generate-input --help exited with status $csem_generate_input_status"
     exit 1
 fi

echo "All tests passed."
