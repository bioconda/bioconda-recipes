#! /bin/bash

echo -e ">seq1\nATTA\n>seq2\nATTA\n>seq3\nATTA\n>seq4\nATTA" > dummy.fasta
echo "(((seq1:0.001,seq2:0.002):0.001,seq3:0.005):0.004,seq4:0.003):0.001;" > dummy.nwk
echo -e "y\ny\ny\ny\ny\n" | cluster-picker dummy.fasta dummy.nwk
rm dummy.fasta
rm dummy.nwk
