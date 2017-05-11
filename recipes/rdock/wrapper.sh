#!/bin/bash
set -euo pipefail

PROGNAME=$(basename "$0")
export RBT_ROOT="CHANGEME"

"$RBT_ROOT/bin/$PROGNAME" "$@"
