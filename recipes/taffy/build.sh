#!/usr/bin/env bash
set -euo pipefail
set -x

pwd
ls -lah
python -V

# Install python package
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation

# Require Makefile for CLI build
if [[ ! -f "Makefile" && ! -f "makefile" ]]; then
  echo "ERROR: No Makefile found. This source archive likely doesn't contain the CLI build system."
  echo "Top-level contents:"
  ls -lah
  exit 1
fi

# Help some builds find host libs (htslib, etc.)
export CFLAGS="${CFLAGS:-} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"

make -j${CPU_COUNT}

# Install CLI binary into conda prefix
mkdir -p "${PREFIX}/bin"
if [[ -x "./taffy" ]]; then
  install -m 0755 ./taffy "${PREFIX}/bin/taffy"
elif [[ -x "./bin/taffy" ]]; then
  install -m 0755 ./bin/taffy "${PREFIX}/bin/taffy"
else
  echo "ERROR: Built, but couldn't find 'taffy' executable to install."
  echo "Candidates:"
  find . -maxdepth 3 -type f -name "taffy" -o -name "taffy*" -print
  exit 1
fi
