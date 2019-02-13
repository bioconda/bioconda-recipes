#!/bin/bash

# Recent versions of fastq_screen need an HTML template to be accessible. To
# test this we do a quick run with a fake fastq, reference fasta, and
# bowtie2 index.

cat > /tmp/tmp.fastq << EOF
@1
ACGACTACGACTACGACTGACTGGGCTCGAAA
+
IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
EOF

cat > /tmp/tmp.fa << EOF
>chr1
ACGACTACGACTACGACTGACTGGGCTCGAAA
EOF

cat > /tmp/conf << EOF
DATABASE tmp /tmp/ref
EOF
bowtie2-build /tmp/tmp.fa /tmp/ref
fastq_screen --force --outdir /tmp  --conf /tmp/conf --aligner bowtie2 /tmp/tmp.fastq

[[ -e /tmp/tmp_screen.html ]]
