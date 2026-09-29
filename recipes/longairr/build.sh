#!/usr/bin/env bash

set -euo pipefail

share_dir="${PREFIX}/share/longairr"
script_dir="${share_dir}/longairr_scripts"

mkdir -p "${PREFIX}/bin" "${share_dir}/docs/images_design/images"

install -m 0644 README.md "${share_dir}/README.md"
install -m 0644 LICENSE "${share_dir}/LICENSE"
install -m 0755 install.sh "${share_dir}/install.sh"

cp -R longairr_scripts "${share_dir}/"
cp -R longairr_example_workflow "${share_dir}/"

install -m 0644 \
  docs/images_design/images/longairr_logo_small.png \
  "${share_dir}/docs/images_design/images/longairr_logo_small.png"
install -m 0644 \
  docs/images_design/images/longairr_profiling_overview.png \
  "${share_dir}/docs/images_design/images/longairr_profiling_overview.png"

find "${script_dir}" -maxdepth 1 -type f -exec chmod 0755 {} +
find "${script_dir}/db_scripts" -maxdepth 1 -type f ! -name LICENSE -exec chmod 0755 {} +

install -m 0755 "${RECIPE_DIR}/longairr_wrapper.sh" "${PREFIX}/bin/longairr"
install -m 0755 "${RECIPE_DIR}/longairr_setup.sh" "${PREFIX}/bin/longairr-setup"
