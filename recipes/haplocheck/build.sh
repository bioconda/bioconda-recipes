#!/bin/sh

curl -SL https://github.com/genepi/haplocheck/releases/download/v1.3.3/haplocheck.zip -o haplocheck.zip
unzip haplocheck.zip

mkdir -p "${PREFIX}/bin"
cp cloudgene.yaml rCRS.fasta mutserve.jar haplocheck haplocheck.jar "${PREFIX}/bin/"
