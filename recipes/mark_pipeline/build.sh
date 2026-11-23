#!/bin/bash
set -euo pipefail
# Scripts, references and annotation files live together in share/, because MARK.sh and MARK-I.sh find their data
# beside themselves (they follow symlinks). bin/ holds links to the two pipelines and small wrappers for the Python tools.
SHARE="${PREFIX}/share/${PKG_NAME}"
mkdir -p "${SHARE}" "${PREFIX}/bin"
for f in MARK.sh MARK-I.sh MARKLaunch.py MARK_mixture_check.py MARK_het_decompose.py SequenceAnalyzerApp_v3.py \
         VCF_OrganizerApp.py vcf_compare_guiv3.py linearized_mtdna.fasta linearized_mtdna.fasta.fai \
         linearized_mtdna.fasta.mmi linearized_regions.bed rCRS.fasta CRM_Nested_inserts.bed CRM_Nested_products.bed \
         CRM_Nested_primers_empirical.bed MARK_Adapter_List_Illumina.txt MARK_Adapter_List_ONT.txt Test_M.fastq \
         mark_logo.png mark_icon_dark.png; do
  cp "${f}" "${SHARE}/"
done
chmod +x "${SHARE}"/*.sh "${SHARE}"/*.py
ln -s "../share/${PKG_NAME}/MARK.sh" "${PREFIX}/bin/MARK.sh"
ln -s "../share/${PKG_NAME}/MARK-I.sh" "${PREFIX}/bin/MARK-I.sh"
# Python tools: a wrapper runs the real file in share/, so each tool finds the files beside it
for tool in MARKLaunch.py SequenceAnalyzerApp_v3.py VCF_OrganizerApp.py vcf_compare_guiv3.py; do
  cat > "${PREFIX}/bin/${tool}" <<WRAP
#!/usr/bin/env bash
exec python "\$(cd "\$(dirname "\$0")" && pwd)/../share/${PKG_NAME}/${tool}" "\$@"
WRAP
  chmod +x "${PREFIX}/bin/${tool}"
done
