#!/usr/bin/env bash

set -euxo pipefail

mkdir -p "${PREFIX}/share/baysor"
cp -r bin/baysor/* "${PREFIX}/share/baysor/"

mkdir -p "${PREFIX}/bin"

cat << 'EOF' > "${PREFIX}/bin/baysor"
#!/usr/bin/env bash
set -euo pipefail

exec "${CONDA_PREFIX}/share/baysor/bin/baysor" "$@"
EOF

chmod +x "${PREFIX}/bin/baysor"