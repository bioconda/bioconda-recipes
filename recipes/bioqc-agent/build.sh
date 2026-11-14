#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$PREFIX/bin" "$PREFIX/share/bioqc-agent"
cp -R src "$PREFIX/share/bioqc-agent/"
cp -R config "$PREFIX/share/bioqc-agent/"

cat > "$PREFIX/bin/bioqc-agent" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${CONDA_PREFIX:-}" ]]; then
    echo "Activate the Conda environment containing bioqc-agent first." >&2
    exit 1
fi
export PYTHONPATH="${CONDA_PREFIX}/share/bioqc-agent${PYTHONPATH:+:${PYTHONPATH}}"
exec python -m src.run_pipeline \
    --config "${CONDA_PREFIX}/share/bioqc-agent/config/qc_thresholds.yaml" \
    "$@"
EOF
chmod +x "$PREFIX/bin/bioqc-agent"
