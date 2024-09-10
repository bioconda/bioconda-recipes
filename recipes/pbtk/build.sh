#!/usr/bin/env bash

mkdir -p "${PREFIX}"/bin

cp bam2fasta "${PREFIX}"/bin/
chmod +x "${PREFIX}"/bin/bam2fasta

cp bam2fastq "${PREFIX}"/bin/
chmod +x "${PREFIX}"/bin/bam2fastq

cp ccs-kinetics-bystrandify "${PREFIX}"/bin/
chmod +x "${PREFIX}"/bin/ccs-kinetics-bystrandify

cp extracthifi "${PREFIX}"/bin/
chmod +x "${PREFIX}"/bin/extracthifi

cp pbindex "${PREFIX}"/bin/
chmod +x "${PREFIX}"/bin/pbindex

cp pbindexdump "${PREFIX}"/bin/
chmod +x "${PREFIX}"/bin/pbindexdump

cp pbmerge "${PREFIX}"/bin/
chmod +x "${PREFIX}"/bin/pbmerge

cp zmwfilter "${PREFIX}"/bin/
chmod +x "${PREFIX}"/bin/zmwfilter
