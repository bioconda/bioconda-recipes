#!/bin/bash -x

# -e = exit on first error
# -x = print every executed command
set -ex

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/bin/scripts

# Install utils
for util in $(ls utils/*); do
    install -m 755 ${util} ${PREFIX}/bin/
done

# Install haphic
install -m 755 haphic ${PREFIX}/bin/

# Install scripts
for script in $(ls scripts/*); do
    install -m 755 ${script} ${PREFIX}/bin/scripts/
done