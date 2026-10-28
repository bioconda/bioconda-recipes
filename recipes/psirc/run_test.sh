#!/usr/bin/env bash
set -euo pipefail

# Verify that the installed script can find FAlite without a custom PERL5LIB.
unset PERL5LIB
cat > genome.fa <<'EOF'
>chr1
ACGTACGTACGTACGT
EOF
printf 'chr1\ttest\texon\t1\t4\t.\t+\t.\tgene_name "gene1"; transcript_id "tx1"; exon_number "1";\n' > annotation.gtf
printf 'chr1\ttest\texon\t9\t12\t.\t+\t.\tgene_name "gene1"; transcript_id "tx1"; exon_number "2";\n' >> annotation.gtf

create_custom_transcriptome_fa.pl genome.fa annotation.gtf transcriptome.fa
cat > expected.fa <<'EOF'
>chr1:0-12_tx1;gene1_Exon_Lengths_4,4_Offsets_0,8_+
ACGTACGT
EOF
cmp transcriptome.fa expected.fa

# Exercise the native fork beyond its version command.
kallisto_b index -k 5 -i transcriptome.idx transcriptome.fa
test -s transcriptome.idx
