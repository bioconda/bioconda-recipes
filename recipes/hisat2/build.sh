#!/bin/bash

mkdir -p $PREFIX/bin

if [ $PY3K -eq 1 ]
then
    2to3 --write \
	hisat2_extract_exons.py \
	hisat2_extract_snps_haplotypes_UCSC.py \
	hisat2_extract_splice_sites.py \
	hisat2-build hisat2-inspect \
	hisat2_simulate_reads.py \
	hisat2_extract_snps_haplotypes_VCF.py \
	hisatgenotype_build_genome.py \
	hisatgenotype_extract_reads.py \
	hisatgenotype_extract_vars.py \
	hisatgenotype_hla_cyp.py \
	hisatgenotype_locus.py \
	hisatgenotype.py
fi

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
    hisat2_extract_exons.py \
    hisat2_extract_snps_haplotypes_UCSC.py \
    hisat2_extract_snps_haplotypes_VCF.py \
    hisat2_extract_splice_sites.py \
    hisat2_simulate_reads.py \
    hisatgenotype_build_genome.py \
    hisatgenotype_extract_reads.py \
    hisatgenotype_extract_vars.py \
    hisatgenotype_hla_cyp.py \
    hisatgenotype_locus.py \
    hisatgenotype.py;
do
    echo $i
    cp $i $PREFIX/bin
    chmod +x $PREFIX/bin/$i
done

for i in \
    hisatgenotype_modules/hisatgenotype_assembly_graph.py \
    hisatgenotype_modules/hisatgenotype_convert_codis.py \
    hisatgenotype_modules/hisatgenotype_extract_codis_data.py \
    hisatgenotype_modules/hisatgenotype_extract_cyp_data.py \
    hisatgenotype_modules/hisatgenotype_gene_typing.py \
    hisatgenotype_modules/hisatgenotype_typing_common.py ;
do
   echo $i
   cp $i $PREFIX/lib/python${PY_VER}/site-packages
done

cp -r example $PREFIX/bin

