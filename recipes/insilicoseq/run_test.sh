#!/usr/bin/env bash
set -eo pipefail

gunzip bogus-genome.fasta.gz
iss generate --model MiSeq --seed 42 --cpus 1 --draft bogus-genome.fasta -n 100 -o bogus-reads
md5sum -c checksums.md5
