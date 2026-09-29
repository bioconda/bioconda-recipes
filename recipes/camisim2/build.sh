#!/usr/bin/env bash
set -euo pipefail

# 1) Install pipeline sources
mkdir -p "${PREFIX}/share/${PKG_NAME}"
cp -R . "${PREFIX}/share/${PKG_NAME}/"

# 2) Create bin dir
mkdir -p "${PREFIX}/bin"

# 3) Write launcher
cat > "${PREFIX}/bin/camisim2" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/CAMI-challenge/CAMISIM"
DOC_URL="${REPO_URL}/wiki/Configuration-File-Options"

usage() {
  cat <<USAGE
camisim2 - CAMISIM launcher

Running camisim2 without any options will start a small test run. To use your own configuration, see 
${DOC_URL}


Quick start:
  camisim2 -c <metagenomic/metatranscriptomic.config> [nextflow options...]

USAGE
}

case "${1:-}" in
  -h|--help|help)
    usage
    exit 0
    ;;
esac

PIPELINE_DIR="${CONDA_PREFIX}/share/camisim2"
exec nextflow run "${PIPELINE_DIR}/main.nf" "$@"
EOF

chmod +x "${PREFIX}/bin/camisim2"

