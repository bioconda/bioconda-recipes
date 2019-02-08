#!/usr/bin/env sh
mykrobe --help
mykrobe predict --help
mykrobe variants --help
mykrobe genotype --help

# only run quick tests as per bioconda guidelines
pytest tests/metagenomics_tests \
    tests/predict_tests \
    tests/stats_tests \
    tests/typer_tests
