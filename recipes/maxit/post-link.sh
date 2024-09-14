#!/bin/bash

mkdir -p ${PREFIX}/etc/conda/{activate,deactivate}.d

# For POSIX Shell(e.g. Bash, Zsh)
echo $'#!/bin/sh\n\n'"export RCSBROOT=${PREFIX}"$'\n' > "${PREFIX}/etc/conda/activate.d/env_vars.sh"
echo $'#!/bin/sh\n\n'"unset RCSBROOT"$'\n' > "${PREFIX}/etc/conda/deactivate.d/env_vars.sh"

# For Fish
echo $'#!/usr/bin/env fish\n\n'"set -gx RCSBROOT ${PREFIX}"$'\n' > "${PREFIX}/etc/conda/activate.d/env_vars.fish"
echo $'#!/usr/bin/env fish\n\n'"set -e RCSBROOT ${PREFIX}"$'\n' > "${PREFIX}/etc/conda/deactivate.d/env_vars.fish"

echo "RCSBROOT will be set to ${PREFIX} when this conda environment is activated."
