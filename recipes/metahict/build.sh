#!/usr/bin/env bash
set -euo pipefail

install -d "${PREFIX}/share/metahict"
install -d "${PREFIX}/bin"

install -m 0644 LICENSE "${PREFIX}/share/metahict/LICENSE"
install -m 0644 README.md "${PREFIX}/share/metahict/README.md"
install -m 0644 metahict_manager.py \
  "${PREFIX}/share/metahict/metahict_manager.py"
install -m 0755 metahict \
  "${PREFIX}/share/metahict/metahict"

cp -R docs "${PREFIX}/share/metahict/"
cp -R images "${PREFIX}/share/metahict/"
cp -R installation "${PREFIX}/share/metahict/"
cp -R modules "${PREFIX}/share/metahict/"
cp -R nextflow "${PREFIX}/share/metahict/"

cat > "${PREFIX}/bin/metahict" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

prefix_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

exec "${prefix_dir}/bin/python" \
  "${prefix_dir}/share/metahict/metahict_manager.py" "$@"
EOF

cat > "${PREFIX}/bin/metahict-nextflow" <<'EOF'
#!/usr/bin/env python3
import os
from pathlib import Path
import sys

prefix_dir = Path(__file__).resolve().parents[1]
workflow = prefix_dir / "share" / "metahict" / "nextflow" / "main_dsl2.nf"

os.execvp(
    "nextflow",
    ["nextflow", "run", str(workflow), *sys.argv[1:]],
)
EOF

chmod 0755 "${PREFIX}/bin/metahict"
chmod 0755 "${PREFIX}/bin/metahict-nextflow"