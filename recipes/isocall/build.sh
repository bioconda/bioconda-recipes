#!/bin/bash
set -euo pipefail

# Install the binary
mkdir -p "${PREFIX}/bin"
install -m 0755 binary/isocall "${PREFIX}/bin/isocall"
