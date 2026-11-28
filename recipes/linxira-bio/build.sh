#!/usr/bin/env bash
set -euo pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo build --release --locked \
  -p linxira-bio-cli \
  -p linxira-bio-mcp \
  -p linxira-bio-worker

TARGET_ROOT="${CARGO_TARGET_DIR:-target}"
BIN_DIR="${TARGET_ROOT}/release"
if [ -n "${CARGO_BUILD_TARGET:-}" ]; then
  BIN_DIR="${TARGET_ROOT}/${CARGO_BUILD_TARGET}/release"
fi

mkdir -p "${PREFIX}/bin"
install -m 755 "${BIN_DIR}/linxira-bio" "${PREFIX}/bin/linxira-bio"
install -m 755 "${BIN_DIR}/linxira-bio-mcp" "${PREFIX}/bin/linxira-bio-mcp"
install -m 755 "${BIN_DIR}/linxira-bio-worker" "${PREFIX}/bin/linxira-bio-worker"

mkdir -p "${PREFIX}/share/linxira-bio"
cp -R workflows "${PREFIX}/share/linxira-bio/workflows"
cp -R capabilities "${PREFIX}/share/linxira-bio/capabilities"

mkdir -p "${PREFIX}/etc/conda/activate.d" "${PREFIX}/etc/conda/deactivate.d"
cat > "${PREFIX}/etc/conda/activate.d/linxira-bio.sh" <<'EOF'
if [ -z "${LINXIRA_BIO_WORKFLOW_ROOT:-}" ]; then
  export LINXIRA_BIO_WORKFLOW_ROOT="${CONDA_PREFIX}/share/linxira-bio/workflows"
fi
EOF
cat > "${PREFIX}/etc/conda/deactivate.d/linxira-bio.sh" <<'EOF'
if [ "${LINXIRA_BIO_WORKFLOW_ROOT:-}" = "${CONDA_PREFIX}/share/linxira-bio/workflows" ]; then
  unset LINXIRA_BIO_WORKFLOW_ROOT
fi
EOF
