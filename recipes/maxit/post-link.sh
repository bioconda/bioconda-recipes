#!/bin/bash

mkdir -p ${PREFIX}/etc/conda/{activate,deactivate}.d

# For POSIX Shell(e.g. Bash, Zsh)

## On activation
echo $'#!/bin/sh\n\n'"export RCSBROOT=${PREFIX}"$'\n' > "${PREFIX}/etc/conda/activate.d/env_vars.sh"
echo $'echo Environment variable \`RCSBROOT\` has set to '\`"${PREFIX}"\`.$'\n' > "${PREFIX}/etc/conda/activate.d/env_vars.sh"

## On deactivation
echo $'#!/bin/sh\n\n'"unset RCSBROOT"$'\n' > "${PREFIX}/etc/conda/deactivate.d/env_vars.sh"
echo $'echo Environment variable \`RCSBROOT\` has unset.\n' > "${PREFIX}/etc/conda/deactivate.d/env_vars.sh"

# For Fish

## On activation
echo $'#!/usr/bin/env fish\n\n'"set -gx RCSBROOT ${PREFIX}"$'\n' > "${PREFIX}/etc/conda/activate.d/env_vars.fish"
echo $'echo Environment variable \`RCSBROOT\` has set to '\`"${PREFIX}"\`.$'\n' > "${PREFIX}/etc/conda/activate.d/env_vars.fish"

## On deactivation
echo $'#!/usr/bin/env fish\n\n'"set -e RCSBROOT ${PREFIX}"$'\n' > "${PREFIX}/etc/conda/deactivate.d/env_vars.fish"
echo $'echo Environment variable \`RCSBROOT\` has unset.\n' > "${PREFIX}/etc/conda/deactivate.d/env_vars.fish"

echo "RCSBROOT will be set to ${PREFIX} when this conda environment is activated."
