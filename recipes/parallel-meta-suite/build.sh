#!/bin/bash
set -euo pipefail

echo "===== BUILD PARALLEL-META SUITE ${PKG_VERSION} ====="

# PMS Makefile writes executables into ./bin
mkdir -p bin

echo "===== BUILD PMS CORE ====="
make CC="${CXX}"

echo "===== BUILD PM-PROFILER ====="
make -C PM-profiler CC="${CXX}"

mkdir -p "${PREFIX}/bin"
echo "===== INSTALL PM-INSTALL ====="
cp "${RECIPE_DIR}/pm-install.sh" "${PREFIX}/bin/PM-install"
chmod 755 "${PREFIX}/bin/PM-install"

echo "===== INSTALL EXECUTABLES ====="
mkdir -p "${PREFIX}/bin"
cp bin/PM-* "${PREFIX}/bin/"
chmod 755 "${PREFIX}"/bin/PM-*

# Runtime root used by $ParallelMETA
ParallelMETA_path="${PREFIX}/${PKG_NAME}-${PKG_VERSION}"
mkdir -p "${ParallelMETA_path}"

echo "===== INSTALL PMS RESOURCES ====="
cp -a Rscript "${ParallelMETA_path}/"

chmod +x "${ParallelMETA_path}"/Rscript/PM_*.R 2>/dev/null || true

echo "===== INSTALL CONDA ACTIVATION SCRIPTS ====="
mkdir -p \
    "${PREFIX}/etc/conda/activate.d" \
    "${PREFIX}/etc/conda/deactivate.d"

cat > "${PREFIX}/etc/conda/activate.d/parallel-meta-suite.sh" <<ACTIVATE
export _PMS_OLD_PARALLELMETA="\${ParallelMETA-}"
export ParallelMETA="${ParallelMETA_path}"
ACTIVATE

cat > "${PREFIX}/etc/conda/deactivate.d/parallel-meta-suite.sh" <<'DEACTIVATE'
if [ -n "${_PMS_OLD_PARALLELMETA+x}" ]; then
    if [ -n "${_PMS_OLD_PARALLELMETA}" ]; then
        export ParallelMETA="${_PMS_OLD_PARALLELMETA}"
    else
        unset ParallelMETA
    fi
    unset _PMS_OLD_PARALLELMETA
else
    unset ParallelMETA
fi
DEACTIVATE

echo "===== BUILD CONTENT ====="
find "${PREFIX}/bin" -maxdepth 1 -type f -name 'PM-*' -printf '%f\n' | sort

echo "ParallelMETA=${ParallelMETA_path}"
