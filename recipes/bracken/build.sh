#!/bin/bash

mkdir -p "${PREFIX}"/bin/src

# inject compilers
sed -i.bak "s#g++#${CXX} -I${PREFIX}/include#" src/Makefile
rm src/*.bak

sh install_bracken.sh
cp -rf bracken "${PREFIX}"/bin
cp -rf bracken-build "${PREFIX}"/bin
cp -rf src/est_abundance.py "${PREFIX}"/bin/src && chmod +x "${PREFIX}"/bin/src/est_abundance.py
ln -sf "${PREFIX}"/bin/src/est_abundance.py "${PREFIX}"/bin/est_abundance.py
cp -rf src/generate_kmer_distribution.py "${PREFIX}"/bin/src && chmod +x "${PREFIX}"/bin/src/generate_kmer_distribution.py
ln -sf "${PREFIX}"/bin/src/generate_kmer_distribution.py "${PREFIX}"/bin/generate_kmer_distribution.py
cp -rf src/kmer2read_distr "${PREFIX}"/bin
cp -rf analysis_scripts/combine_bracken_outputs.py "${PREFIX}"/bin && chmod +x "${PREFIX}"/bin/combine_bracken_outputs.py
