#!/usr/bin/env bash
set -euo pipefail

# Conda-build sandboxing:
# Conda-build strips or randomizes HOME, which breaks default Cargo paths (~/.cargo).
# Explicitly anchor CARGO_HOME to the source build directory.
export CARGO_HOME="${SRC_DIR:-$(pwd)}/.cargo"
export CARGO_NET_GIT_FETCH_WITH_CLI=true
export RUST_BACKTRACE=1

# Ensure sandboxed cache cleanup on exit or failure
trap 'rm -rf "$CARGO_HOME"' EXIT

# Bundle third-party licenses required by Bioconda and Conda-Forge policies
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Install the binary into conda prefix bin
cargo install --no-track --locked --verbose --root "${PREFIX}" --path crates/vardictrust

# Install shell completions and manpage when executing natively and supported by the binary
if [ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ] && "${PREFIX}/bin/vardictrust" --help 2>&1 | grep -q -- "--completions"; then
    mkdir -p \
        "${PREFIX}/share/bash-completion/completions" \
        "${PREFIX}/share/zsh/site-functions" \
        "${PREFIX}/share/fish/vendor_completions.d" \
        "${PREFIX}/share/man/man1"
    "${PREFIX}/bin/vardictrust" --completions bash > "${PREFIX}/share/bash-completion/completions/vardictrust"
    "${PREFIX}/bin/vardictrust" --completions zsh > "${PREFIX}/share/zsh/site-functions/_vardictrust"
    "${PREFIX}/bin/vardictrust" --completions fish > "${PREFIX}/share/fish/vendor_completions.d/vardictrust.fish"
    "${PREFIX}/bin/vardictrust" --manpage > "${PREFIX}/share/man/man1/vardictrust.1"
fi

# Clean up temporary cargo cache and install records to prevent bloat
rm -rf "$CARGO_HOME"
rm -f "${PREFIX}/.crates.toml" "${PREFIX}/.crates2.json"
