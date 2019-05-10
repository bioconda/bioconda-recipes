#!/usr/bin/env bash
set -eo pipefail

iss generate --model MiSeq --seed 42 --cpus 1 --draft bogus-genome.fasta -n 100 -o bogus-reads
shasum -c checksums.sha
