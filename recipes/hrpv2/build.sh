#!/usr/bin/env bash
set -euo pipefail

install -d "${PREFIX}/bin" "${PREFIX}/share/hrpv2"
install -m 755 HRPv2.py "${PREFIX}/bin/HRPv2"
install -m 755 run_genblastG "${PREFIX}/bin/run_genblastG"
install -m 644 alignscore.txt "${PREFIX}/share/hrpv2/alignscore.txt"

