#!/bin/bash
# stop on error
set -exu -o pipefail

# taken from yacrd recipe, see: https://github.com/bioconda/bioconda-recipes/blob/2b02c3db6400499d910bc5f297d23cb20c9db4f8/recipes/yacrd/build.sh
if [ "$(uname)" == "Darwin" ]; then

    # apparently the HOME variable isn't set correctly, and circle ci output indicates the following as the home directory
    export HOME=`pwd`
    echo "HOME is $HOME"
    mkdir -p $HOME/.cargo/registry/index/
fi

# download and run a small assembly
rm -f ./hifi.fastq.gz ./ont.fastq.gz
curl -L https://obj.umiacs.umd.edu/sergek/shared/ecoli_hifi_subset24x.fastq.gz -o hifi.fastq.gz
curl -L https://obj.umiacs.umd.edu/sergek/shared/ecoli_ont_subset50x.fastq.gz -o ont.fastq.gz
if [ "$(uname)" == "Darwin" ]; then
   verkko -d asm --no-correction --hifi ./hifi.fastq.gz
else
   verkko -d asm --no-correction --hifi ./hifi.fastq.gz --nano ./ont.fastq.gz
fi
python $PREFIX/lib/verkko/scripts/circularize_ctgs.py -p 10 -f 0.01 -o asm/assembly_circular.fasta --min-ovl 1000 asm/assembly.fasta


if [ ! -s asm/assembly_circular.fasta ]; then
   echo "Error: verkko assembly test failed!"
   tail -n +1 `find asm -name *.err`
   exit 1
fi

echo "Finished verkko assembly test!"
exit 0
