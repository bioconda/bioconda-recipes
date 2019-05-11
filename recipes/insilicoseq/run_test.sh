#!/usr/bin/env bash
set -eo pipefail

curl -L https://ndownloader.figshare.com/files/15127220 > bogus-genome.fasta
curl -L https://ndownloader.figshare.com/files/15127661 > checksums.md5

iss generate --model MiSeq --seed 42 --cpus 1 --draft bogus-genome.fasta -n 100 -o bogus-reads
md5sum -c checksums.md5
