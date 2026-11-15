#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${PREFIX}/share/harmonize_amr"
mkdir -p "${INSTALL_DIR}/bin" "${PREFIX}/bin"

# Install the Snakemake workflow.
if [[ ! -f "${SRC_DIR}/workflow/Snakefile" ]]; then
    echo "Required workflow/Snakefile is missing" >&2
    exit 1
fi

cp -R "${SRC_DIR}/workflow" "${INSTALL_DIR}/"

# Install additional runtime directories, if present.
for directory in config scripts templates src; do
    if [[ -d "${SRC_DIR}/${directory}" ]]; then
        cp -R "${SRC_DIR}/${directory}" "${INSTALL_DIR}/"
    fi
done

# Install standalone Python entry points and version files.
for filename in run_harmonize_amr.py harmonize_amr.py VERSION RELEASE_DATE; do
    if [[ -f "${SRC_DIR}/${filename}" ]]; then
        install -m 0644 \
            "${SRC_DIR}/${filename}" \
            "${INSTALL_DIR}/${filename}"
    fi
done

# Install the three public command-line entry points.
for command in run_harmonize_amr harmonize_amr update_databases.sh; do
    if [[ ! -f "${SRC_DIR}/bin/${command}" ]]; then
        echo "Missing entry point: bin/${command}" >&2
        exit 1
    fi

    install -m 0755 \
        "${SRC_DIR}/bin/${command}" \
        "${INSTALL_DIR}/bin/${command}"

    cat > "${PREFIX}/bin/${command}" <<'WRAPPER'
#!/usr/bin/env bash
set -euo pipefail
BIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
INSTALL_DIR="${BIN_DIR}/../share/harmonize_amr"
exec "${INSTALL_DIR}/bin/$(basename -- "${BASH_SOURCE[0]}")" "$@"
WRAPPER

    chmod 0755 "${PREFIX}/bin/${command}"
done
