#!/bin/bash
# stop on error
set -eu -o pipefail

# download and run a small assembly

rm -f ./lamba_ont.fasta.gz
curl -L https://obj.umiacs.umd.edu/sergek/shared/lambda_ont.fasta.gz -o lambda_ont.fasta.gz
canu -p asm -d asm useGrid=false genomeSize=21k -fast maxMemory=6 maxThreads=2 mhapMemory=1 corMemory=6 corThreads=2 redThreads=2 redMemory=4 oeaMemory=4 -nanopore lambda_ont.fasta.gz || tail -n +1 `find asm -name *.out`

if [ ! -s asm/asm.contigs.fasta ] || [ ! -s asm/asm.report ]; then
   echo "Error: canu assembly test failed!"
   exit 1
fi

echo "Finished canu assembly test!"
exit 0
