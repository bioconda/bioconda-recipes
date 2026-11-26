#!/usr/bin/env bash
set -euxo pipefail

mkdir -p "${PREFIX}/bin"

install -m 755 "${SRC_DIR}/Treemmer_v${PKG_VERSION}.py" "${PREFIX}/bin/Treemmer.py"

# Wrapper that silences warnings (e.g. ete3 SyntaxWarnings on newer Python)
cat > "${PREFIX}/bin/treemmer" << 'EOF'
#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${DIR}/python" -W ignore "${DIR}/Treemmer.py" "$@"
EOF
chmod 755 "${PREFIX}/bin/treemmer"
