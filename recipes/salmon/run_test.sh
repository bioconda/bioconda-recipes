#!/usr/bin/env bash
tar xzf sample_data.tgz
salmon index -t sample_data/transcripts.fasta -i salmon_index
salmon quant -i salmon_index -l IU -1 sample_data/reads_1.fastq -2 sample_data/reads_2.fastq -o sample_sa_quant -p 4
salmon quant -t sample_data/transcripts.fasta -l IU -a sample_data/sample_alignments.bam -o sample_aln_quant -p 4
