#!/usr/bin/env bash

# Run all Parsnp tests
curl https://github.com/marbl/harvest/raw/master/docs/content/parsnp/mers_examples.tar.gz -L --output mers_examples.tar.gz
tar -xzvf mers_examples.tar.gz

# CPU=$(grep -c ^processor /proc/cpuinfo)
CPU=2
parsnp -V 
parsnp -g mers_virus/ref/England1.gbk -d mers_virus/genomes -C 1000 -c -o test-gbk --verbose --use-fasttree --vcf
parsnp -r ! -d mers_virus/genomes/*.fna -o test-skips --verbose -p $CPU --force-overwrite --skip-phylogeny --skip-ani-filter
parsnp -r ! -d mers_virus/genomes/*.fna -o test-mash --verbose -p $CPU --skip-phylogeny --use-mash
# parsnp -r mers_virus/ref/England1.fna -d mers_virus/genomes/*.fna -o test-fastani --verbose -p $CPU --skip-phylogeny --use-ani #Skip for MacOS but fix in future build
parsnp -r ! -d mers_virus/genomes/*.fna -o test-nopartition --verbose -p $CPU --no-partition --xtrafast
parsnp -r ! -d mers_virus/genomes/*.fna -o test-minpartition10 --verbose -p $CPU --min-partition-size 10 --xtrafast

