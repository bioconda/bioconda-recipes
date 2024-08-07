#!/bin/bash -e

# Copy python scripts into somewhere in the env
mkdir -p "${PREFIX}/share/kosudoku"
cp -r ./programs/* "${PREFIX}/share/kosudoku/"

# Copy bash wrappers to somewhere in the path
cp ./bash_wrappers/kosudoku-* "${PREFIX}/bin/"
chmod +x ${PREFIX}/bin/kosudoku*

