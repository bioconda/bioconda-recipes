#!/bin/bash
set -euo pipefail

# End-to-end functional test: build a tiny reference and an indexed BAM carrying
# a single planted SNV, then confirm vardictcpp reads FASTA/BAM through htslib and
# calls the variant. Uses only bash, printf, grep and samtools (test requirement).
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cd "$work"

REFSEQ="ACGTTGCAACCTTGGCCAATTGGCCAAGGTTCCAAGGTTCCACGTACGTTGCAACCTTGGCCAATTGGCCAAGGTTCCAAGGTTCCACGTACGTTGCAACCTTGGCCAATTGGCCAAGGTT"
printf '>chr1\n%s\n' "$REFSEQ" > ref.fa
samtools faidx ref.fa
reflen=${#REFSEQ}
read0=${REFSEQ:0:60}

# flip reference base 30 to a different base in every read -> a clean SNV at chr1:30
b=${read0:29:1}
case "$b" in A) n=T;; C) n=G;; G) n=C;; *) n=A;; esac
readvar="${read0:0:29}${n}${read0:30}"
qual="${readvar//?/I}"   # one 'I' per base, same length as the read

{
  printf '@HD\tVN:1.6\tSO:coordinate\n'
  printf '@SQ\tSN:chr1\tLN:%s\n' "$reflen"
  for i in 1 2 3 4 5 6 7 8 9 10 11 12; do
    printf 'r%s\t0\tchr1\t1\t60\t60M\t*\t0\t0\t%s\t%s\n' "$i" "$readvar" "$qual"
  done
} > reads.sam
samtools sort -o test.bam reads.sam
samtools index test.bam
printf 'chr1\t0\t%s\tgene1\n' "$reflen" > regions.bed

vardictcpp -G ref.fa -f 0.01 -N sample -b test.bam -c 1 -S 2 -E 3 -g 4 regions.bed > out.tsv
cat out.tsv
grep -qF "$(printf 'chr1\t30\t30\t%s\t%s' "$b" "$n")" out.tsv
echo "OK: vardictcpp read the FASTA/BAM and called the planted SNV"
