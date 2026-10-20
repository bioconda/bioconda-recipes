#!/bin/bash

set -euo pipefail

test_dir="amulet-fragment-workflow-test"
rm -rf "${test_dir}"
mkdir -p "${test_dir}/out"

cat > "${test_dir}/cells.csv" <<'EOF'
barcode,is__cell_barcode
cellA,1
cellB,1
cellC,1
EOF

cat > "${test_dir}/chromosomes.txt" <<'EOF'
chr1
chr2
EOF

cat > "${test_dir}/repeats.bed" <<'EOF'
chr9	1	2
EOF

cat > "${test_dir}/fragments.tsv" <<'EOF'
chr1	100	150	cellA	1
chr1	110	160	cellA	1
chr1	120	170	cellA	1
chr1	200	250	cellB	1
chr1	210	260	cellB	1
chr1	220	270	cellB	1
chr1	300	350	cellC	1
chr1	310	360	cellC	1
chr1	320	370	cellC	1
chr1	400	450	cellC	1
chr1	410	460	cellC	1
chr1	420	470	cellC	1
chr2	1	10	cellA	1
EOF

amulet \
  "${test_dir}/fragments.tsv" \
  "${test_dir}/cells.csv" \
  "${test_dir}/chromosomes.txt" \
  "${test_dir}/repeats.bed" \
  "${test_dir}/out"

test "$(wc -l < "${test_dir}/out/Overlaps.txt")" -eq 5
test "$(wc -l < "${test_dir}/out/OverlapSummary.txt")" -eq 4
test "$(wc -l < "${test_dir}/out/MultipletProbabilities.txt")" -eq 4
grep -q $'cellC\t6\t2\tcellC\t6' "${test_dir}/out/OverlapSummary.txt"
grep -q $'Number of Cells\t3' "${test_dir}/out/MultipletSummary.txt"

rm -rf "${test_dir}"
