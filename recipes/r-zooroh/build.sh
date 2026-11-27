#!/bin/bash
set -euo pipefail
cp "$PREFIX/lib/R/share/licenses/GPL-3" LICENSE
"$R" CMD INSTALL --build .
