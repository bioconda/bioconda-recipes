#!/usr/bin/env bash
# Bioconda build script for SpaCNA (noarch: generic).
#
# SpaCNA GitHub release ships a prebuilt conda package under dist/:
#   dist/spacna-<version>-*.tar.bz2
# which already contains:
#   bin/spacna
#   share/spacna/{scripts,reference,bin,config,...}
#
# This script unpacks that package into $PREFIX and installs thin wrappers so
# `spacna` works even when CONDA_PREFIX is unset during tests.
set -euo pipefail

SHARE_DIR="${PREFIX}/share/spacna"
BIN_DIR="${PREFIX}/bin"

mkdir -p "${SHARE_DIR}" "${BIN_DIR}"

# Resolve payload path for both:
# - cwd already inside SpaCNA-<version>/ (normal conda-build)
# - cwd is parent of SpaCNA-<version>/ (some folder:/CI layouts)
if ! compgen -G "dist/spacna-*.tar.bz2" >/dev/null; then
  FOUND="$(find . -maxdepth 3 -type f -name 'spacna-*.tar.bz2' | head -n 1 || true)"
  if [[ -n "${FOUND}" ]]; then
    cd "$(dirname "${FOUND}")/.."
  fi
fi

PKG="$(ls -1 dist/spacna-*.tar.bz2 2>/dev/null | head -n 1 || true)"
if [[ -z "${PKG}" ]]; then
  echo "ERROR: no dist/spacna-*.tar.bz2 found in source tree" >&2
  echo "cwd=$(pwd)" >&2
  ls -la >&2 || true
  find . -maxdepth 3 -type f -name 'spacna-*.tar.bz2' >&2 || true
  exit 1
fi

echo "Installing SpaCNA payload from ${PKG}"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

# conda package layout: bin/ + share/spacna/
tar -xjf "${PKG}" -C "${TMP}"

if [[ ! -d "${TMP}/share/spacna" ]]; then
  echo "ERROR: ${PKG} missing share/spacna/" >&2
  exit 1
fi
if [[ ! -f "${TMP}/bin/spacna" ]]; then
  echo "ERROR: ${PKG} missing bin/spacna" >&2
  exit 1
fi

# Copy pipeline tree (scripts, reference, config, docs, ...)
tar -C "${TMP}/share/spacna" \
    --exclude='build_env_setup.sh' \
    --exclude='conda_build.sh' \
    --exclude='conda_env_hint.txt' \
    --exclude='metadata_conda_debug.yaml' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    -cf - . | tar -C "${SHARE_DIR}" -xf -

# Keep payload CLI under share/spacna/bin (resolves via ../scripts)
mkdir -p "${SHARE_DIR}/bin"
cp -f "${TMP}/bin/spacna" "${SHARE_DIR}/bin/spacna"
chmod +x "${SHARE_DIR}/bin/spacna"
if [[ -f "${TMP}/bin/axis-dna" ]]; then
  cp -f "${TMP}/bin/axis-dna" "${SHARE_DIR}/bin/axis-dna"
  chmod +x "${SHARE_DIR}/bin/axis-dna"
fi

# Thin wrappers in $PREFIX/bin: do not rely on CONDA_PREFIX being set
cat > "${BIN_DIR}/spacna" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${HERE}/../share/spacna" && pwd)"
export SPACNA_REPO_ROOT="${ROOT}"
export AXIS_REPO_ROOT="${ROOT}"
exec bash "${ROOT}/bin/spacna" "$@"
EOF
chmod +x "${BIN_DIR}/spacna"

if [[ -f "${SHARE_DIR}/bin/axis-dna" ]]; then
  cat > "${BIN_DIR}/axis-dna" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${HERE}/../share/spacna" && pwd)"
export SPACNA_REPO_ROOT="${ROOT}"
export AXIS_REPO_ROOT="${ROOT}"
exec bash "${ROOT}/bin/axis-dna" "$@"
EOF
  chmod +x "${BIN_DIR}/axis-dna"
fi

find "${SHARE_DIR}/scripts" -type f \( -name '*.sh' -o -name '*.py' \) -exec chmod +x {} + 2>/dev/null || true

cat > "${SHARE_DIR}/conda_env_hint.txt" <<EOF
SpaCNA (bioconda)
Package root: ${SHARE_DIR}
CLI: spacna

R: cd "\$(spacna path)" && source("scripts/R/spacna.R")
EOF
