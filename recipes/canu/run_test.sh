#!/bin/bash
# stop on error
set -eu -o pipefail

# download and run a small assembly

rm -f ./lamba_ont.fasta.gz
curl -L https://obj.umiacs.umd.edu/sergek/shared/lambda_ont.fasta.gz -o lambda_ont.fasta.gz
canu -p asm -d asm useGrid=false genomeSize=21k -fast maxMemory=8 maxThreads=4 -nanopore lambda_ont.fasta.gz

if [ ! -s asm/asm.contigs.fasta ] || [ ! -s asm/asm.report ]; then
   echo "Error: canu assembly test failed!"
   exit 1
fi

echo "Finished canu assembly test!"
exit 0
