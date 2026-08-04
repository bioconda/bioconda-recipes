#!/usr/bin/env bash
# Bioconda build script for SpaCNA (noarch: generic).
#
# SpaCNA GitHub release ships a prebuilt conda package under dist/:
#   dist/spacna-<version>-*.tar.bz2
# which already contains:
#   bin/spacna
#   share/spacna/{scripts,reference,bin,config,...}
#
# This script unpacks that package into $PREFIX.
set -euo pipefail

SHARE_DIR="${PREFIX}/share/spacna"
BIN_DIR="${PREFIX}/bin"

mkdir -p "${SHARE_DIR}" "${BIN_DIR}"

PKG="$(ls -1 dist/spacna-*.tar.bz2 2>/dev/null | head -n 1 || true)"
if [[ -z "${PKG}" ]]; then
  echo "ERROR: no dist/spacna-*.tar.bz2 found in source tree" >&2
  echo "cwd=$(pwd)" >&2
  ls -la >&2 || true
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
if [[ ! -x "${TMP}/bin/spacna" && ! -f "${TMP}/bin/spacna" ]]; then
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

install -m 0755 "${TMP}/bin/spacna" "${BIN_DIR}/spacna"
if [[ -f "${TMP}/bin/axis-dna" ]]; then
  install -m 0755 "${TMP}/bin/axis-dna" "${BIN_DIR}/axis-dna"
fi

# Keep a copy under share for `spacna path` users
mkdir -p "${SHARE_DIR}/bin"
cp -f "${BIN_DIR}/spacna" "${SHARE_DIR}/bin/spacna"
chmod +x "${SHARE_DIR}/bin/spacna"
if [[ -f "${BIN_DIR}/axis-dna" ]]; then
  cp -f "${BIN_DIR}/axis-dna" "${SHARE_DIR}/bin/axis-dna"
  chmod +x "${SHARE_DIR}/bin/axis-dna"
fi

find "${SHARE_DIR}/scripts" -type f \( -name '*.sh' -o -name '*.py' \) -exec chmod +x {} + 2>/dev/null || true

# Prefer LICENSE from payload if recipe license_file needs it at source root;
# bioconda copies LICENSE from source before build — SpaCNA repo root already has LICENSE.

cat > "${SHARE_DIR}/conda_env_hint.txt" <<EOF
SpaCNA (bioconda)
Package root: ${SHARE_DIR}
CLI: spacna

R: cd "\$(spacna path)" && source("scripts/R/spacna.R")
EOF
