#!/bin/bash
set -euo pipefail

# Conda attempts to set a lower hardening level without unsetting the define,
# while AdapterRemoval sets -D_FORTIFY_SOURCE=3 by default. This fixes the
# build, silences warnings, and preserves the higher hardening level
export CPPFLAGS="-U_FORTIFY_SOURCE ${CPPFLAGS} -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3"

# Required to build documentation with sphinx
export LC_ALL="en_US.UTF-8"

meson setup "build" --prefix="${PREFIX}" 
meson compile -C "build" adapterremoval3
meson install -C "build"
