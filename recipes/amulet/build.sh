#!/bin/bash

set -euo pipefail

share_dir="${PREFIX}/share/amulet"
mkdir -p "${PREFIX}/bin" "${share_dir}"

install -m 0644 AMULET.py FragmentFileOverlapCounter.py peakoverlap.py \
  human_autosomes.txt snATACOverlapCounter.jar "${share_dir}/"

install -m 0755 AMULET.sh "${share_dir}/AMULET.sh"

cat > "${PREFIX}/bin/amulet" <<'EOF'
#!/bin/bash
set -euo pipefail

share_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../share/amulet" && pwd)"

if [[ "$#" -eq 0 ]]; then
    echo "Usage: amulet [options] input.{bam,tsv,txt,tsv.gz,txt.gz} barcodemap chromosomelist repeatfilter outputdirectory"
    exit 0
fi

exec "${share_dir}/AMULET.sh" "$@" "${share_dir}"
EOF

cat > "${PREFIX}/bin/amulet-fragment-overlap-counter" <<'EOF'
#!/bin/bash
set -euo pipefail

share_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../share/amulet" && pwd)"
exec python "${share_dir}/FragmentFileOverlapCounter.py" "$@"
EOF

cat > "${PREFIX}/bin/amulet-multiplet-detection" <<'EOF'
#!/bin/bash
set -euo pipefail

share_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../share/amulet" && pwd)"
exec python "${share_dir}/AMULET.py" "$@"
EOF

chmod 0755 \
  "${PREFIX}/bin/amulet" \
  "${PREFIX}/bin/amulet-fragment-overlap-counter" \
  "${PREFIX}/bin/amulet-multiplet-detection"
