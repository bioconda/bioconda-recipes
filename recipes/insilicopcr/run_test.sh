#!/usr/bin/env bash
# A 600-base genome with one 400-base product, as an assembly (BLAST+) and as reads (BBTools, then BLAST+).
# test-F melts at 50.9 C on its site: ta=50 judges the assay at 50 C (since insilicoPCR 2.0, a site needs ta - 5).
set -euo pipefail
insilicoPCR --version | grep -qxF "insilicoPCR ${PKG_VERSION}"
insilicopcr --help > /dev/null

GENOME=TCAGTGAGACGATGGCAACCTACGTAACGCCGATTCGACGAAATCTTATGACCTTTCTTCTAGATCTCGATTTGTTTGGGTCCTGGAATGGGAACTCATACTGTACAATATCTTGACTAACAGTTAATCATCATAGAATGGAGGTTTCCCTTCTACGCGCCTCTCGGTCATACTTCCGCCAGGATTTCAGTCTTATGGACACTGTTGTACGCTGCTTCCCCCTTCAGGTGGCGGTTCACATAAGGCTCCGTTCTGATGATCCCGTCAGCAGCGCGGCGGATCTAATAGTCGTGCTGTGGGTTAAACATATCAGTGAATGTCCACACCAGAGTACCTTGTGTTTGTCCGTCGGCTCCCTTGTGCCGCTAGCTTTACCCGTCCCCGGGTGCCGCGTGTCACCTGGCCCGTATTTCAGATAAGGACTATACAAATAGTAGTTGCTCGAAAGACAGCATAAAAACGTAAGTAATACGTGTGCCAGATATTGAGAATCGCTTTGCTCTAAATTTATGTAAATTTAGTACAGATTTCTGGCGGTCCCGAGCGAGTTCCTTGGCGGGCGGATGGGTTCATGAGATGCCACGAAGATGACTATGATAG
mkdir -p genomes reads
printf '>test-F size=400 ta=50\nCTGTACAATATCTTGACTAA\n>test-R\nGCAAAGCGATTCTCAATATC\n' > primers.fasta
printf '>contig_1\n%s\n' "${GENOME}" > genomes/sample.fasta

# Read pairs of 100 bases from 250-base fragments, one every 2 bases.
QUALITY="$(printf 'I%.0s' $(seq 100))"
for ((start = 0; start + 250 <= ${#GENOME}; start += 2)); do
  fragment="${GENOME:start:250}"
  mate="$(printf '%s' "${fragment: -100}" | rev | tr ACGT TGCA)"
  printf '@r%d/1\n%s\n+\n%s\n' "${start}" "${fragment:0:100}" "${QUALITY}" >> reads/sample_R1.fastq
  printf '@r%d/2\n%s\n+\n%s\n' "${start}" "${mate}" "${QUALITY}" >> reads/sample_R2.fastq
done

for input in genomes reads; do
  insilicoPCR -i "${input}" -p primers.fasta -o "out_${input}" -t 2
  report="out_${input}/consolidated_report/report.tsv"
  cat "${report}"
  [[ "$(awk -F '\t' 'NR == 1 { for (i = 1; i <= NF; i++) c[$i] = i; next }
        { print $c["Assay"], $c["AmpliconSize"], $c["SizeCheck"] }' "${report}")" == "test 400 target" ]]
done
grep -F "BBTools Location: ${PREFIX}/opt/bbmap" out_reads/QAlog.txt
