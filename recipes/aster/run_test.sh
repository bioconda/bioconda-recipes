#!/usr/bin/env bash
set -euo pipefail

# Package activation must preserve library paths supplied by the caller.
export CONDA_PREFIX="${PREFIX}"
export LD_LIBRARY_PATH=/__aster_test_existing_library_path__
export SINGULARITYENV_LD_LIBRARY_PATH=/__aster_test_singularity_library_path__
for hook in "${PREFIX}"/etc/conda/activate.d/aster_*.sh; do
    if [[ -f "${hook}" ]]; then
        source "${hook}"
    fi
done
[[ "${LD_LIBRARY_PATH}" == /__aster_test_existing_library_path__ ]]
[[ "${SINGULARITYENV_LD_LIBRARY_PATH}" == /__aster_test_singularity_library_path__ ]]
