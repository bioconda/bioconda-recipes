#!/bin/bash

mkdir -p ${PREFIX}/bin

make CC=${CC} CPP=${CXX}


# convert Python 2.7 scripts to 3
if [ $PY3K -eq 1 ]
then
    2to3 --write \
        extract_exons.py \
        extract_splice_sites.py \
        hisat2_extract_exons.py \
        hisat2_extract_snps_haplotypes_UCSC.py \
        hisat2_extract_snps_haplotypes_VCF.py \
        hisat2_extract_splice_sites.py \
        hisat2_read_statistics.py \
        hisat2_simulate_reads.py \
        hisatgenotype_build_genome.py \
        hisatgenotype_extract_reads.py \
        hisatgenotype_extract_vars.py \
        hisatgenotype_hla_cyp.py \
        hisatgenotype_locus.py \
        hisatgenotype_modules/hisatgenotype_assembly_graph.py \
        hisatgenotype_modules/hisatgenotype_typing_common.py \
        hisatgenotype_scripts/compare_HLA_Omixon.py \
        hisatgenotype_scripts/extract_Omixon_HLA.py \
        hisatgenotype_scripts/hisatgenotype_HLA_genotyping_PGs.py \
        hisatgenotype_scripts/hisatgenotype_locus_samples.py \
        hisatgenotype_scripts/compare_HLA.py \
        hisatgenotype_scripts/hisatgenotype_convert_codis.py \
        hisatgenotype_scripts/hisatgenotype_extract_codis_data.py \
        hisatgenotype_scripts/hisatgenotype_extract_cyp_data.py \
        hisatgenotype.py
fi

# copy binaries and python scripts
for i in \
    hisat2 \
    hisat2-align-l \
    hisat2-align-s \
    hisat2-build \
    hisat2-build-l \
    hisat2-build-s \
    hisat2-inspect \
    hisat2-inspect-l \
    hisat2-inspect-s \
    *.py \
    hisatgenotype_scripts/*.*;
do
    cp ${i} ${PREFIX}/bin
done

# modules needed in PYTHONPATH
for i in \
    hisatgenotype_modules/hisatgenotype_assembly_graph.py \
    hisatgenotype_modules/hisatgenotype_typing_common.py ;
do
   cp ${i} ${PREFIX}/lib/python${PY_VER}/site-packages
done

# set permissions
chmod +x ${PREFIX}/bin/*
