#!/usr/bin/env bash
set -euo pipefail

# In build.sh you generate this file into $PREFIX/bin/camisim2
cat > "${PREFIX}/bin/camisim2" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/CAMI-challenge/CAMISIM"
DOC_URL="${REPO_URL}/wiki/Configuration-File-Options

usage() {
  cat <<USAGE
camisim2 - CAMISIM launcher

Configuration and usage:
  See ${DOC_URL}

If you run the command ./camisim2 without any options, CAMISIM will simulate a small test data set

Notes:
  This wrapper runs the packaged Nextflow workflow:
    ${CONDA_PREFIX}/share/camisim2/main.nf
USAGE
}

# Handle help without invoking Nextflow
case "${1:-}" in
  -h|--help|help)
    usage
    exit 0
    ;;
esac

# Otherwise run Nextflow
PIPELINE_DIR="${CONDA_PREFIX}/share/camisim2"
exec nextflow run "${PIPELINE_DIR}/main.nf" "$@"
EOF

chmod +x "${PREFIX}/bin/camisim2"

