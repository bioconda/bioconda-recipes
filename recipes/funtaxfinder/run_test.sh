#!/usr/bin/env bash
set -euo pipefail

cat > asv_table.tsv <<'EOF'
ASV_ID	Sample1	Sample2
ASV1	10	0
ASV2	0	5
EOF

cat > combined_KO_predicted.tsv <<'EOF'
ASV_ID	K02586	K02588
ASV1	1.5	0
ASV2	0	2.0
EOF

funtaxfinder \
    --asv-table asv_table.tsv \
    --ko K02586 \
    --ko-predicted combined_KO_predicted.tsv \
    --outdir test_output

test -s test_output/sub_asv_table.tsv
test -s test_output/matched_asv_summary.tsv
test -s test_output/run_summary.txt

grep -q $'^ASV1\t' test_output/sub_asv_table.tsv

if grep -q $'^ASV2\t' test_output/sub_asv_table.tsv; then
    echo "ASV2 should not have matched K02586" >&2
    exit 1
fi
