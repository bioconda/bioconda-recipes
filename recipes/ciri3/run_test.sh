#!/usr/bin/env bash
set -euo pipefail

ciri3 -I data/circRNA/Single/sample.sam -F data/circRNA/ref.fa -O single.txt
cmp single.txt data/circRNA/Single/result.txt

# Exercise both the native rMATS helper and its companion R script on two events.
head -n 3 data/DE/Ratio/BSJ_Matrix.txt > bsj.tsv
head -n 3 data/DE/Ratio/FSJ_Matrix.txt > fsj.tsv
ciri3 DE_Ratio -I data/DE/Ratio/infor.tsv -BM bsj.tsv -FM fsj.tsv -O ratio.tsv
# Upstream appends the compared group names to the requested output prefix.
test -s ratio.tsv_Control_Case
grep -q DeltaPSI ratio.tsv_Control_Case
test "$(wc -l < ratio.tsv_Control_Case)" -eq 3
