#!/bin/bash
set -euo pipefail

# $SRC_DIR is the tarball root — Cargo.toml is at the top level
cd "${SRC_DIR}"

cargo install --locked --no-track --root "${PREFIX}" --path .

# Install shell tab-completion scripts
mkdir -p "${PREFIX}/share/bash-completion/completions"
mkdir -p "${PREFIX}/share/zsh/site-functions"
mkdir -p "${PREFIX}/share/fish/vendor_completions.d"

"${PREFIX}/bin/sharkmer" --completions bash > "${PREFIX}/share/bash-completion/completions/sharkmer"
"${PREFIX}/bin/sharkmer" --completions zsh  > "${PREFIX}/share/zsh/site-functions/_sharkmer"
"${PREFIX}/bin/sharkmer" --completions fish > "${PREFIX}/share/fish/vendor_completions.d/sharkmer.fish"
