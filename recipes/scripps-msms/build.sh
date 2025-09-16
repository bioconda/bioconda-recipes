#!/usr/bin/env bash

set -euxo pipefail

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/share/msms"
mkdir -p "${PREFIX}/man/man1"
mkdir -p "${PREFIX}/doc"

# Look for `atmtypenumbers` in the library folder instead of the current folder
sed -i.bak "s|numfile = \"./atmtypenumbers\"|numfile = \"$PREFIX/share/msms/atmtypenumbers\"|" pdb_to_xyzr
sed -i.bak "s|numfile = \"./atmtypenumbers\"|numfile = \"$PREFIX/share/msms/atmtypenumbers\"|" pdb_to_xyzrn

install -m644 ./atmtypenumbers "${PREFIX}/share/msms/"
install -m644 msms.1 "${PREFIX}/man/man1/"
install -m644 msms.html "${PREFIX}/doc/"
install -m755 ./pdb_to_xyzr "${PREFIX}/bin/pdb_to_xyzr"
install -m755 ./pdb_to_xyzrn "${PREFIX}/bin/pdb_to_xyzrn"
install -m755 ./msms*${PKG_VERSION} "${PREFIX}/bin/msms"
