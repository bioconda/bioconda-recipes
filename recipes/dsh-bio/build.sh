#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $BINARY_HOME
mkdir -p $PACKAGE_HOME

cp -R * $PACKAGE_HOME

ln -s $PACKAGE_HOME/bin/dsh-bio $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-compress-bed $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-compress-fasta $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-compress-fastq $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-compress-gaf $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-compress-gfa1 $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-compress-gfa2 $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-compress-gff3 $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-compress-paf $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-compress-rgfa $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-compress-sam $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-compress-vcf $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-create-sequence-dictionary $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-disinterleave-fastq $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-downsample-fastq $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-downsample-interleaved-fastq $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-export-segments $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-extract-fastq $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-extract-fastq-by-length $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-fasta-to-fastq $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-fastq-description $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-fastq-sequence-length $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-fastq-to-bam $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-fastq-to-fasta $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-fastq-to-text $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-filter-bed $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-filter-fasta $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-filter-fastq $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-filter-gaf $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-filter-gfa1 $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-filter-gfa2 $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-filter-gff3 $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-filter-paf $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-filter-rgfa $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-filter-sam $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-filter-vcf $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-gfa1-to-gfa2 $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-identify-gfa1 $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-interleave-fastq $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-interleaved-fastq-to-bam $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-links-to-cytoscape-edges $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-links-to-property-graph $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-reassemble-paths $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-remap-dbsnp $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-remap-phase-set $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-rename-bed-references $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-rename-gff3-references $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-rename-vcf-references $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-segments-to-cytoscape-nodes $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-segments-to-property-graph $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-split-bed $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-split-fasta $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-split-fastq $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-split-gaf $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-split-gff3 $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-split-interleaved-fastq $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-split-paf $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-split-sam $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-split-vcf $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-text-to-fastq $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-traversals-to-cytoscape-edges $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-traversals-to-property-graph $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-traverse-paths $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-truncate-fasta $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-truncate-paths $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-variant-table-to-vcf $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-vcf-header $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-vcf-pedigree $BINARY_HOME
ln -s $PACKAGE_HOME/bin/dsh-vcf-samples $BINARY_HOME
