#!/usr/bin/env bash

set -euo pipefail

prefix="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
share_dir="${prefix}/share/longairr"
setup_dir="$(mktemp -d "${TMPDIR:-/tmp}/longairr-setup.XXXXXXXX")"

cleanup() {
  rm -rf "${setup_dir}"
}
trap cleanup EXIT

install -m 0755 "${share_dir}/install.sh" "${setup_dir}/install.sh"
cp -R "${share_dir}/longairr_scripts" "${setup_dir}/longairr_scripts"

if [[ $# -eq 0 ]]; then
  set -- --help
fi

cd "${setup_dir}"

bash ./install.sh \
  "$@" \
  --env FALSE \
  --scripts-dir ./longairr_scripts/
 
