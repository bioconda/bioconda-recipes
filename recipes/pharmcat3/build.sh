#!/usr/bin/env bash
set -euo pipefail

# Debug mode for CI logs
set -x

mkdir -p "${PREFIX}/bin"
mkdir -p "${SP_DIR}/pcat"

# Install CLI scripts
if [[ -f pharmcat ]]; then
  install -m 0755 pharmcat "${PREFIX}/bin/pharmcat"
fi
install -m 0755 pharmcat_pipeline "${PREFIX}/bin/pharmcat_pipeline"
install -m 0755 pharmcat_vcf_preprocessor "${PREFIX}/bin/pharmcat_vcf_preprocessor"

# Install JAR and accessory files alongside scripts (scripts look in their own dir)
if [[ -f pharmcat.jar ]]; then
  install -m 0644 pharmcat.jar "${PREFIX}/bin/pharmcat.jar"
fi
if [[ -f pharmcat_positions.vcf.bgz ]]; then
  install -m 0644 pharmcat_positions.vcf.bgz "${PREFIX}/bin/pharmcat_positions.vcf.bgz"
fi
if [[ -f pharmcat_positions.vcf.bgz.csi ]]; then
  install -m 0644 pharmcat_positions.vcf.bgz.csi "${PREFIX}/bin/pharmcat_positions.vcf.bgz.csi"
fi
if [[ -f pharmcat_regions.bed ]]; then
  install -m 0644 pharmcat_regions.bed "${PREFIX}/bin/pharmcat_regions.bed"
fi

# Install Python module used by the scripts
if compgen -G "pcat/*.py" > /dev/null; then
  cp -a pcat/*.py "${SP_DIR}/pcat/"
fi
if compgen -G "pcat/*.tsv" > /dev/null; then
  cp -a pcat/*.tsv "${SP_DIR}/pcat/"
fi

chmod 0755 "${PREFIX}/bin/pharmcat_pipeline" "${PREFIX}/bin/pharmcat_vcf_preprocessor" || true
[[ -f "${PREFIX}/bin/pharmcat" ]] && chmod 0755 "${PREFIX}/bin/pharmcat" || true

set +x
echo "PharmCAT installed to ${PREFIX}"
