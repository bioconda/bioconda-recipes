#!/bin/bash
set -e
set -o pipefail
set -x

# Tests degenotate on a small test dataset that includes a genome fasta, annotation gff, and
# vcf file.

TMP=$(mktemp -d)
cd $TMP
wget https://github.com/harvardinformatics/degenotate/raw/main/test-data/vcf/test.fa.gz
wget https://github.com/harvardinformatics/degenotate/raw/main/test-data/vcf/test.gff
wget https://github.com/harvardinformatics/degenotate/raw/main/test-data/vcf/test.vcf.gz
wget https://github.com/harvardinformatics/degenotate/raw/main/test-data/vcf/test.vcf.gz.tbi

degenotate.py -a test.gff -g test.fa.gz -v test.vcf.gz -u SAMEA3516844 -o test-out/
