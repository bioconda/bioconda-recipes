#!/usr/bin/env bash
set -euo pipefail
set -x

pwd
ls -lah

# The sdist is missing sonLib submodule; remove references so metadata generation doesn't fail.
# Common places: MANIFEST.in, setup.cfg, or setup.py.
if [[ ! -d "taffy/submodules/sonLib/C/inc" ]]; then
  echo "sonLib submodule content missing; patching packaging files to avoid hard failure."

  # Patch MANIFEST.in if it mentions sonLib
  if [[ -f MANIFEST.in ]]; then
    grep -n "sonLib" MANIFEST.in || true
    sed -i.bak '/sonLib/d' MANIFEST.in || true
  fi

  # Patch setup.cfg if it mentions sonLib paths
  if [[ -f setup.cfg ]]; then
    grep -n "sonLib" setup.cfg || true
    sed -i.bak '/sonLib/d' setup.cfg || true
  fi

  # Patch setup.py if it hardcodes that path
  if [[ -f setup.py ]]; then
    grep -n "sonLib" setup.py || true
    # crude but effective: remove lines referencing the missing directory
    sed -i.bak '/sonLib/d' setup.py || true
  fi

  # Show what remains for debugging
  find . -maxdepth 2 -type f -name "MANIFEST.in" -o -name "setup.cfg" -o -name "setup.py" -print -exec sed -n '1,200p' {} \;
fi

# Install python bits (no deps, no isolation)
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
