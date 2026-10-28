#!/usr/bin/env bash

set -e -o pipefail -x

# Workaround for SSH-based git connections from cargo, and point CARGO_HOME
# somewhere writable (HOME is not passed on to conda-build).
export CARGO_NET_GIT_FETCH_WITH_CLI=true
export CARGO_HOME="$(pwd)/.cargo"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Upstream does not ship a Cargo.lock (it is git-ignored), so --locked cannot be used.
cargo install -v --no-track --root "${PREFIX}" --path .
rm -f "${PREFIX}/.crates.toml" "${PREFIX}/.crates2.json"

# ngless looks up the external tools it drives in $NGLESS_*_BIN, falling back to
# $PATH. Wrap the binary so the copies from this environment are always the ones
# used, even when the environment has not been activated.
#
# The prefix is derived from the wrapper's own location rather than from
# $CONDA_PREFIX: that variable is unset unless the environment is activated, and
# it points at the wrong environment when a different one is active. Note that a
# NGLESS_*_BIN that is set but does not point at an executable is a hard error in
# ngless (there is no fallback to $PATH), so getting this wrong is fatal.
mv "${PREFIX}/bin/ngless" "${PREFIX}/bin/ngless-wrapped"
cat > "${PREFIX}/bin/ngless" <<'EOF'
#!/usr/bin/env bash

bindir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

export NGLESS_SAMTOOLS_BIN="${bindir}/samtools"
export NGLESS_BWA_BIN="${bindir}/bwa"
export NGLESS_PRODIGAL_BIN="${bindir}/prodigal"
export NGLESS_MEGAHIT_BIN="${bindir}/megahit"
export NGLESS_MINIMAP2_BIN="${bindir}/minimap2"

exec "${bindir}/ngless-wrapped" "$@"
EOF
chmod +x "${PREFIX}/bin/ngless"
