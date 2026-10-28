#!/bin/bash
set -euxo pipefail

SEQ="CCTACGGGAGGCAGCAGTGGGGAATATTGCACAATGGGCGCAAGCCTGATGCAGCCATGCCGCGTGTATGAAGAAGGCCTTCGGGTTGTAAAGTACTTTCAGCGGGGAGGAAGGGAGTAAAGTTAATACCTTTGCTCATTGACGTTACCCGCAGAAGAAGCACCGGCTAACTCCGTGCCAGCAGCCGCGGTAATAC"
RC="GTATTACCGCGGCTGCTGGCACGGAGTTAGCCGGTGCTTCTTCTGCGGGTAACGTCAATGAGCAAAGGTATTAACTTTACTCCCTTCCTCCCCGCTGAAAGTACTTTACAACCCGAAGGCCTTCTTCATACACGCGGCATGGCTGCATCAGGCTTGCGCCCATTGTGCAATATTCCCCACTGCTGCCTCCCGTAGG"

printf '# STOCKHOLM 1.0\ntoy %s\n//\n' "${SEQ}" > toy.sto
hmmbuild --dna -n toy toy.hmm toy.sto > /dev/null

mkdir -p hmms
for origin in bacteria archaea eukaryota mitochondria chloroplast; do
  cp toy.hmm "hmms/${origin}.hmm"
done

printf '>fwd\nGATTACAGATTACA%sGATTACAGATTACA\n>rev\n%s\n>junk\nACGTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTACGT\n' \
  "${SEQ}" "${RC}" > reads.fasta

ssuplex -i reads.fasta -o out/smoke --hmm-dir hmms -t 2

test -s out/smoke.extraction.tsv
test -s out/smoke.summary.txt

n_classified=$(awk -F'\t' 'NR > 1 && $2 != "unclassified" { n++ } END { print n + 0 }' out/smoke.extraction.tsv)
test "${n_classified}" -eq 2

awk -F'\t' '$1 == "junk" && $2 == "unclassified" { found = 1 } END { exit !found }' out/smoke.extraction.tsv
