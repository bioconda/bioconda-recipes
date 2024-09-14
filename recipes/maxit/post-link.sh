#!/bin/bash

mkdir -p "${PREFIX}/etc/conda/{activate.d,deactivate.d}"
if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
    echo $'#!/bin/sh\n\n'"export RCSBROOT=${PREFIX}"$'\n' > "${PREFIX}/etc/conda/activate.d/env_vars.sh"
    echo $'#!/bin/sh\n\n'"unset RCSBROOT"$'\n' > "${PREFIX}/etc/conda/deactivate.d/env_vars.sh"
elif [ -n "$FISH_VERSION" ]; then
    echo $'#!/usr/bin/env fish\n\n'"set -gx RCSBROOT ${PREFIX}"$'\n' > "${PREFIX}/etc/conda/activate.d/env_vars.fish"
    echo $'#!/usr/bin/env fish\n\n'"set -e RCSBROOT ${PREFIX}"$'\n' > "${PREFIX}/etc/conda/deactivate.d/env_vars.fish"
else
    echo "Unsupported shell: $SHELL"
    exit 1
fi

echo "RCSBROOT will be set to ${PREFIX} when this conda environment is activated."
