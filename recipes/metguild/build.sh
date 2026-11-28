
#!/usr/bin/env bash
set -euo pipefail

# Create installation directories.
mkdir -p "${PREFIX}/share/metguild/scripts"
mkdir -p "${PREFIX}/bin"

# Install the existing MetGuild launcher.
install -m 0755 run_metguild_workflow.sh \
    "${PREFIX}/share/metguild/run_metguild_workflow.sh"

# Install the Python workflow scripts.
install -m 0644 scripts/*.py \
    "${PREFIX}/share/metguild/scripts/"

# Install the version file.
install -m 0644 VERSION \
    "${PREFIX}/share/metguild/VERSION"

# Create an executable command named metguild.
cat > "${PREFIX}/bin/metguild" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec bash \
  "${BIN_DIR}/../share/metguild/run_metguild_workflow.sh" \
  "$@"
EOF

chmod +x "${PREFIX}/bin/metguild"
