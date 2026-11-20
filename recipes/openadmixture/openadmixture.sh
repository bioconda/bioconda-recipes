#!/usr/bin/env bash
# openadmixture launcher installed by the bioconda package.
#   openadmixture [ADMIXTURE options] input.bed K
# Runs the bundled Julia on the bundled, precompiled environment, offline.
# Julia fixes its thread count at start-up, so ADMIXTURE's -jN is read here.
set -euo pipefail

src="${BASH_SOURCE[0]}"
while [[ -L "$src" ]]; do
    dir="$(cd "$(dirname "$src")" && pwd)"
    src="$(readlink "$src")"
    [[ "$src" != /* ]] && src="$dir/$src"
done
prefix="$(cd "$(dirname "$src")/.." && pwd)"
share="$prefix/share/openadmixture"

threads=1
prev=""
for a in "$@"; do
    if [[ "$prev" == "-j" ]]; then
        threads="$a"
    elif [[ "$a" =~ ^-j([0-9]+)$ ]]; then
        threads="${BASH_REMATCH[1]}"
    fi
    prev="$a"
done

# The bundled depot is read-only. Julia writes any cache it has to rebuild (e.g. on
# a CPU the package was not compiled for) into the first depot: a per-user one.
user_depot="${OPENADMIXTURE_DEPOT:-${XDG_CACHE_HOME:-$HOME/.cache}/openadmixture/@VERSION@}"
# The trailing ":" adds Julia's bundled depots (precompiled stdlibs), not ~/.julia.
export JULIA_DEPOT_PATH="$user_depot:$share/depot:"
export JULIA_LOAD_PATH="@:@stdlib"
export JULIA_PKG_OFFLINE=true
unset JULIA_PROJECT JULIA_CPU_TARGET

exec "$share/julia/bin/julia" --project="$share/env" --startup-file=no --history-file=no \
    -t "$threads" -e 'using OpenADMIXTURE; exit(OpenADMIXTURE.main(ARGS))' -- "$@"
