#!/usr/bin/env bash
set -euxo pipefail


# Make sure the conda-provided C++ compiler is used
# Replace any hard-coded 'g++' with '$(CXX)' in the Makefile
# (portable sed usage for both GNU and BSD sed)
if grep -qE '(^|\s)g\+\+(\s|$)' Makefile; then
  sed -E -i.bak 's/(^|[[:space:]])g\+\+([[:space:]]|$)/\1\$(CXX)\2/g' Makefile
fi

# Build MyTaxa
make CXX="${CXX:-c++}"

# Install MyTaxa binaries into the conda prefix
mkdir -p "${PREFIX}/bin"
cp -v MyTaxa "${PREFIX}/bin/"

# Install utils
mkdir -p "${PREFIX}/share/mytaxa"
cp -rv utils "${PREFIX}/share/mytaxa/"

