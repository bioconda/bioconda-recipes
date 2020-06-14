#!/usr/bin/env bash

curl https://github.com/marbl/harvest/raw/master/docs/content/parsnp/mers_examples.tar.gz -L --output mers_examples.tar.gz
tar -xzvf mers_examples.tar.gz
parsnp -V 
parsnp -g mers_virus/ref/England1.gbk -d mers_virus/genomes/*.fna -C 1000 -c -o test --verbose --use-fasttree
parsnp -r ! -d mers_virus/genomes/*.fna -o test2 --verbose
parsnp -g mers_virus/ref/England1.gbk -d mers_virus/genomes/*.fna -p 5 -C 1000 -c -o test --verbose --use-fasttree
parsnp -r ! -d mers_virus/genomes/*.fna -o test2 --verbose -p 5
