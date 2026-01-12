#!/usr/bin/env bash
set -eux

# should use "install -m 755 ...." here
mkdir -p "${PREFIX}/bin"
chmod 755 iupak
cp iupak "${PREFIX}/bin/"
