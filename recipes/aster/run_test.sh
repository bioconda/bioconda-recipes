#!/usr/bin/env bash
set -euo pipefail

# ASTER must not install hooks that change library lookup for other programs.
for hook_dir in activate.d deactivate.d; do
    for hook in "${PREFIX}/etc/conda/${hook_dir}"/aster_*.sh; do
        if [[ -e "${hook}" || -L "${hook}" ]]; then
            printf 'Unexpected ASTER Conda hook: %s\n' "${hook}" >&2
            exit 1
        fi
    done
done
