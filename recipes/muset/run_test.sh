#!/bin/bash
set -e
# Verbose binary checks
echo "Checking muset binary:"
which muset
muset --help || echo "muset help failed"
echo "Checking muset_pa binary:"
which muset_pa
muset_pa --help || echo "muset_pa help failed"
echo "Checking kmat_tools binary:"
which kmat_tools
kmat_tools --help || echo "kmat_tools help failed"
# Verify executability
test -x $(which muset)
test -x $(which muset_pa)
test -x $(which kmat_tools)
# Additional diagnostic information
echo "Binary versions:"
muset --version || true
muset_pa --version || true
kmat_tools --version || true
# Explicit success
exit 0