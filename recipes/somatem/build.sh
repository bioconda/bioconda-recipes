#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${PREFIX}/share/${PKG_NAME}"
mkdir -p "${PREFIX}/bin"

# Copy the full pipeline repository into the Conda package share dir
cp -a . "${PREFIX}/share/${PKG_NAME}/src_tmp"
cp -a "${PREFIX}/share/${PKG_NAME}/src_tmp"/. "${PREFIX}/share/${PKG_NAME}/"
rm -rf "${PREFIX}/share/${PKG_NAME}/src_tmp"

# Create launcher
cat > "${PREFIX}/bin/${PKG_NAME}" <<EOF
#!/usr/bin/env bash
set -euo pipefail

PIPELINE_DIR="${PREFIX}/share/${PKG_NAME}"

show_help() {
    cat <<'EOM'
somatem: launch the Somatem Nextflow pipeline

Usage:
  somatem [Nextflow pipeline options]

Examples:
  somatem -params-file assets/16S_params.yml
  somatem -params-file assets/custom_metadata.yaml
  somatem --input samplesheet.csv --outdir results -profile conda
  somatem -profile docker --input samplesheet.csv --outdir results

Notes:
  - Relative paths passed to -params-file or --params-file that match files
    inside the installed Somatem pipeline will be resolved automatically.
  - Any other arguments are passed directly to:
      nextflow run <pipeline>/main.nf

Support:
  - If you run into any issues, please feel free to reach out.
  - Repository:
      https://github.com/treangenlab/Somatem
  - Wiki:
      https://github.com/treangenlab/Somatem/wiki
  - You can look through the GitHub wiki pages for documentation on the
    major subworkflows within Somatem.

Help:
  somatem -h
  somatem --help
EOM
}

if [[ "\${1:-}" == "-h" || "\${1:-}" == "--help" ]]; then
    show_help
    exit 0
fi

args=()
while [[ \$# -gt 0 ]]; do
    case "\$1" in
        -params-file|--params-file)
            shift
            pf="\$1"
            if [[ "\$pf" != /* && -f "\${PIPELINE_DIR}/\${pf}" ]]; then
                args+=("-params-file" "\${PIPELINE_DIR}/\${pf}")
            else
                args+=("-params-file" "\$pf")
            fi
            ;;
        *)
            args+=("\$1")
            ;;
    esac
    shift
done

exec nextflow run "\${PIPELINE_DIR}/main.nf" "\${args[@]}"
EOF

chmod +x "${PREFIX}/bin/${PKG_NAME}"