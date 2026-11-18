#!/bin/bash
set -euo pipefail
mkdir -p "$PREFIX/bin" "$PREFIX/share/comet/test/dmr"
install -m 755 bin/comet bin/comet_*.sh bin/comet_*.py "$PREFIX/bin/"
# comet test: bundled per-site BEDs for the comet dmr check (test BAMs are downloaded from Zenodo)
install -m 644 example/data/dmr/*.bed.gz example/data/dmr/*.bed.gz.tbi "$PREFIX/share/comet/test/dmr/"
