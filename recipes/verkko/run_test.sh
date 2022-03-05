#!/bin/bash
# stop on error
set -eu -o pipefail

# download and run a small assembly

rm -f ./hifi.fastq.gz ./ont.fastq.gz
curl -L https://obj.umiacs.umd.edu/sergek/shared/ecoli_hifi_subset24x.fastq.gz -o hifi.fastq.gz
curl -L https://obj.umiacs.umd.edu/sergek/shared/ecoli_ont_subset50x.fastq.gz -o ont.fastq.gz
verkko -d asm --correct-hash-bits 22 --hifi ./hifi.fastq.gz --nano ./ont.fastq.gz

if [ ! -s asm/assembly.fasta ]; then
   echo "Error: verkko assembly test failed!"
   tail -n +1 `find asm -name *.err`
   exit 1
fi

echo "Finished verkko assembly test!"
exit 0
