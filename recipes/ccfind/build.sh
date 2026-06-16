#!/bin/bash
set -euo pipefail

SHARE_DIR="${PREFIX}/share/ccfind"

mkdir -p "${PREFIX}/bin"
mkdir -p "${SHARE_DIR}/script"

# Install main files
cp ccfind "${SHARE_DIR}/ccfind"
cp ccfind.rake "${SHARE_DIR}/ccfind.rake"
cp script/*.rb "${SHARE_DIR}/script/"

chmod +x "${SHARE_DIR}/ccfind"

# Create wrapper script in bin/ that sets correct working context
cat > "${PREFIX}/bin/ccfind" <<'WRAPPER'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
exec "${SCRIPT_DIR}/../share/ccfind/ccfind" "$@"
WRAPPER

chmod +x "${PREFIX}/bin/ccfind"
