#!/usr/bin/env bash
set -eux

# should use "install -m 755 ...." here
mkdir -p "${PREFIX}/bin"
install -m 755 iupak "${PREFIX}/bin/"
