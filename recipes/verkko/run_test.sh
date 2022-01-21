#!/bin/bash
# stop on error
set -eu -o pipefail

# download and run a small assembly

rm -f ./hifi.fastq.gz ./ont.fastq.gz
curl -L https://obj.umiacs.umd.edu/sergek/shared/ecoli_hifi_subset24x.fastq.gz -o hifi.fastq.gz
curl -L https://obj.umiacs.umd.edu/sergek/shared/ecoli_ont_subset50x.fastq.gz -o ont.fastq.gz
verkko -d asm --no-correction --hifi ./hifi.fastq.gz --nano ./ont.fastq.gz --snakeopts "--resources mem_gb=2" --ovb-run 2 2 1 --red-run 2 2 1 --sto-run 2 2 1

if [ ! -s asm/7-consensus/unitig-popped.fasta ]; then
   echo "Error: verkko assembly test failed!"
   tail -n +1 `find asm -name *.err`
   exit 1
fi

echo "Finished verkko assembly test!"
exit 0
