#!/usr/bin/env bash
set -euo pipefail

# Never reuse the x86-64 binary bundled in the upstream source archive.
# setup.py declares pie.module.lib.hamming as an Extension, so pip will use
# Conda's activated C compiler and build the correct binary for this Python ABI
# and target platform.
rm -f pie/pie/module/lib/hamming.so

"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv
