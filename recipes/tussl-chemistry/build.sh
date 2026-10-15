#!/usr/bin/env bash
# Build script for the bioconda recipe (see meta.yaml and packaging/README.md).
set -euo pipefail
# conda-build does not pass HOME through, so keep cargo's registry cache in the work directory.
export CARGO_HOME="${SRC_DIR}/.cargo"
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
# Same code as the release archives: the release profile (panic = abort, overflow checks), built
# from Cargo.lock, without debug info and stripped (.github/workflows/release.yml).
cargo install --no-track --locked --verbose --root "${PREFIX}" --path . \
  --config profile.release.debug=0
# The list fetcher reads ../data/lists.tsv beside its own directory: keep that layout under share/.
share="${PREFIX}/share/tussl-chemistry"
install -d "${share}/scripts" "${share}/data"
install -m 755 scripts/fetch_whitelists.sh "${share}/scripts/"
install -m 644 data/lists.tsv "${share}/data/"
cat > "${PREFIX}/bin/tchem-fetch-whitelists" <<'WRAPPER'
#!/usr/bin/env bash
exec "$(dirname "$0")/../share/tussl-chemistry/scripts/fetch_whitelists.sh" "$@"
WRAPPER
chmod 755 "${PREFIX}/bin/tchem-fetch-whitelists"
