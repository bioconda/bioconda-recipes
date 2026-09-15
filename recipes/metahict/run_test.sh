#!/usr/bin/env bash
set -euo pipefail

installed_root="${PREFIX}/share/metahict"

"${installed_root}/metahict" test workflow
