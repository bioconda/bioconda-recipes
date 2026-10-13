#!/usr/bin/env bash
set -euxo pipefail

mkdir -p "${PREFIX}/bin"

# Install the original script
install -m 755 Treemmer_v0.3.py "${PREFIX}/bin/Treemmer_v0.3.py"

# Wrapper that silences warnings (e.g. ete3 SyntaxWarnings on newer Python)
cat > "${PREFIX}/bin/treemmer" << 'EOF'
#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${DIR}/python" -W ignore "${DIR}/Treemmer_v0.3.py" "$@"
EOF
chmod 755 "${PREFIX}/bin/treemmer"
