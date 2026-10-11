#!/usr/bin/env bash

set -euo pipefail

prefix="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
share_dir="${prefix}/share/longairr"
script_dir="${share_dir}/longairr_scripts"

export PATH="${script_dir}:${PATH}"
export LONGAIRR_LOGO="${share_dir}/docs/images_design/images/longairr_logo_small.png"

exec bash "${script_dir}/longairr.sh" "$@"
