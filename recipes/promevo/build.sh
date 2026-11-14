#!/usr/bin/env bash

set -euo pipefail

echo "=============================================================================="
echo "             BUILDING PromEvo"
echo "=============================================================================="

echo "[INFO] Conda prefix : ${PREFIX}"
echo "[INFO] Source       : ${SRC_DIR}"

PACKAGE_DIR="${PREFIX}/share/comparative-gene-promoter"
SCRIPTS_DIR="${PACKAGE_DIR}/scripts"

mkdir -p "${PREFIX}/bin"
mkdir -p "${PACKAGE_DIR}"
mkdir -p "${SCRIPTS_DIR}"

# =============================================================================
# INSTALL PYTHON PIPELINE SCRIPTS
# =============================================================================

echo
echo "[INFO] Installing Python pipeline scripts..."

cp "${SRC_DIR}"/scripts/*.py "${SCRIPTS_DIR}/"

echo "[OK] Python scripts installed."
echo "     ${SCRIPTS_DIR}"

# =============================================================================
# INSTALL PIPELINE LAUNCHER
# =============================================================================

if [ -f "${SRC_DIR}/scripts/run_pipeline.sh" ]; then
    cp "${SRC_DIR}/scripts/run_pipeline.sh" "${PACKAGE_DIR}/run_pipeline.sh"
    chmod +x "${PACKAGE_DIR}/run_pipeline.sh"
    echo "[OK] Pipeline launcher installed."
else
    echo "[ERROR] scripts/run_pipeline.sh was not found."
    exit 1
fi

# =============================================================================
# INSTALL ENVIRONMENT CHECKER
# =============================================================================

if [ -f "${SRC_DIR}/scripts/environment_check.py" ]; then
    cp "${SRC_DIR}/scripts/environment_check.py" "${PACKAGE_DIR}/environment_check.py"
    echo "[OK] Environment checker installed."
else
    echo "[WARN] environment_check.py was not found."
fi

# =============================================================================
# INSTALL DOCUMENTATION
# =============================================================================

for f in README.md LICENSE.txt AUTHORS.md environment.yml; do
    if [ -f "${SRC_DIR}/${f}" ]; then
        cp "${SRC_DIR}/${f}" "${PACKAGE_DIR}/${f}"
        echo "[OK] ${f} installed."
    fi
done

# =============================================================================
# IDENTIFY MASTER SCRIPT
# =============================================================================

masters=("${SCRIPTS_DIR}"/master_script_*.py)

if [ "${#masters[@]}" -ne 1 ] || [ ! -f "${masters[0]}" ]; then
    echo
    echo "[ERROR] Expected exactly one master_script_*.py."
    echo "        Found ${#masters[@]}."
    exit 1
fi

MASTER_BASENAME="$(basename "${masters[0]}")"

echo "[OK] Master script detected:"
echo "     ${MASTER_BASENAME}"

# =============================================================================
# WRAPPER COMMANDS
#
# Each wrapper locates the environment from its own path (not from whatever
# CONDA_PREFIX happens to be), then exports CONDA_PREFIX and puts the env's
# bin/ first on PATH. Scripts launched by the wrappers (run_pipeline.sh,
# environment_check.py, master script) therefore still see CONDA_PREFIX,
# and a bare "python" resolves to the environment's Python.
# =============================================================================

HEADER='#!/usr/bin/env bash

set -euo pipefail

SELF="$(readlink -f "${BASH_SOURCE[0]}")"
PREFIX_DIR="$(cd "$(dirname "${SELF}")/.." && pwd)"
export CONDA_PREFIX="${PREFIX_DIR}"
export PATH="${PREFIX_DIR}/bin:${PATH}"

PIPELINE_DIR="${PREFIX_DIR}/share/comparative-gene-promoter"
'

# ---- promevo ----------------------------------------------
{
    printf '%s\n' "${HEADER}"
    cat <<'EOF'
case "${1:-}" in
    --authors|--about)
        cat "${PIPELINE_DIR}/AUTHORS.md"
        exit 0
        ;;
esac

if [ ! -f "${PIPELINE_DIR}/run_pipeline.sh" ]; then
    echo "[ERROR] Pipeline launcher not found:"
    echo "        ${PIPELINE_DIR}/run_pipeline.sh"
    exit 1
fi

exec bash "${PIPELINE_DIR}/run_pipeline.sh" "$@"
EOF
} > "${PREFIX}/bin/promevo"

# ---- promevo-master ---------------------------------------
{
    printf '%s\n' "${HEADER}"
    printf 'MASTER="${PIPELINE_DIR}/scripts/%s"\n\n' "${MASTER_BASENAME}"
    cat <<'EOF'
if [ ! -f "${MASTER}" ]; then
    echo "[ERROR] Master script not found:"
    echo "        ${MASTER}"
    exit 1
fi

exec "${PREFIX_DIR}/bin/python" "${MASTER}" "$@"
EOF
} > "${PREFIX}/bin/promevo-master"

# ---- promevo-check ----------------------------------------
{
    printf '%s\n' "${HEADER}"
    cat <<'EOF'
CHECKER="${PIPELINE_DIR}/environment_check.py"

if [ ! -f "${CHECKER}" ]; then
    echo "[ERROR] Environment checker not found:"
    echo "        ${CHECKER}"
    exit 1
fi

exec "${PREFIX_DIR}/bin/python" "${CHECKER}" "$@"
EOF
} > "${PREFIX}/bin/promevo-check"

# ---- promevo-authors --------------------------------------
{
    printf '%s\n' "${HEADER}"
    cat <<'EOF'
if [ ! -f "${PIPELINE_DIR}/AUTHORS.md" ]; then
    echo "[ERROR] AUTHORS.md not found in ${PIPELINE_DIR}"
    exit 1
fi

cat "${PIPELINE_DIR}/AUTHORS.md"
EOF
} > "${PREFIX}/bin/promevo-authors"

chmod +x "${PREFIX}/bin/promevo" \
         "${PREFIX}/bin/promevo-master" \
         "${PREFIX}/bin/promevo-check" \
         "${PREFIX}/bin/promevo-authors"

# =============================================================================
# FINAL BUILD INFORMATION
# =============================================================================

echo
echo "=============================================================================="
echo "                     BUILD INSTALLATION COMPLETE"
echo "=============================================================================="
echo "[INFO] Package directory : ${PACKAGE_DIR}"
echo "[INFO] Scripts directory : ${SCRIPTS_DIR}"
echo "[INFO] Master script     : ${MASTER_BASENAME}"
echo
echo "[INFO] Installed commands:"
echo "       promevo"
echo "       promevo-master"
echo "       promevo-check"
echo "       promevo-authors"
echo
echo "[INFO] Motif databases are NOT packaged."
echo "[INFO] JASPAR and UniProbe databases will be downloaded by Stage 00."
echo
echo "=============================================================================="
