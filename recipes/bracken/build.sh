#!/bin/bash

mkdir -p "${PREFIX}"/bin
sh install_bracken.sh
cp bracken "${PREFIX}"/bin
cp bracken-build "${PREFIX}"/bin
cp src/est_abundance.py "${PREFIX}"/bin && chmod +x "${PREFIX}"/bin/est_abundance.py
cp src/generate_kmer_distribution.py "${PREFIX}"/bin && chmod +x "${PREFIX}"/bin/generate_kmer_distribution.py
cp src/kreport2mpa.py "${PREFIX}"/bin && chmod +x "${PREFIX}"/bin/kreport2mpa.py
cp src/kmer2read_distr "${PREFIX}"/bin
cp analysis_scripts/combine_bracken_outputs.py "${PREFIX}"/bin && chmod +x "${PREFIX}"/bin/combine_bracken_outputs.py
