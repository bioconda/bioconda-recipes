#!/usr/bin/env bash
set -euxo pipefail

# Upstream script still has Python 2-only print statements; convert to Python 3.
2to3 -w -n "${SRC_DIR}/Treemmer.py"

mkdir -p "${PREFIX}/bin"

install -m 755 "${SRC_DIR}/Treemmer.py" "${PREFIX}/bin/Treemmer.py"

cat > "${PREFIX}/bin/treemmer" << 'EOF'
#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${DIR}/python" -W ignore "${DIR}/Treemmer.py" "$@"
EOF
chmod 755 "${PREFIX}/bin/treemmer"
