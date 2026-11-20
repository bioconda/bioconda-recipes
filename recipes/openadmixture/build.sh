#!/usr/bin/env bash
set -euxo pipefail

share="$PREFIX/share/openadmixture"
depot="$share/depot"
mkdir -p "$share" "$depot/dev" "$share/env" "$share/testdata" "$PREFIX/bin"

# 1. Bundled Julia runtime
cp -R "$SRC_DIR/julia" "$share/julia"
julia="$share/julia/bin/julia"

# 2. OpenADMIXTURE source inside the depot, so its precompile caches record
#    @depot-relative paths and stay valid wherever conda installs the package.
cp -R "$SRC_DIR/OpenADMIXTURE.jl" "$depot/dev/OpenADMIXTURE"

# 3. Resolve, download and precompile the dependencies into the bundled depot.
#    Package images are built for the same generic CPU targets as Julia's own system
#    image (e.g. "generic;apple-m1,clone_all"), not for the builder's CPU. Any other
#    target makes Julia recompile the stdlibs into the depot with absolute paths,
#    which are then rejected once conda installs the package elsewhere.
# Separate assignment so that a Julia that fails to start stops the build.
cpu_target="$("$julia" --startup-file=no -e 'print(Sys.sysimage_target())')"
export JULIA_CPU_TARGET="$cpu_target"
export JULIA_DEPOT_PATH="$depot:"   # trailing ":" keeps Julia's bundled depots (precompiled stdlibs)
export JULIA_LOAD_PATH="@:@stdlib"
export JULIA_PKG_PRECOMPILE_AUTO=0
cd "$share/env"
"$julia" --startup-file=no --history-file=no --project=. -e '
    using Pkg
    Pkg.develop(path="../depot/dev/OpenADMIXTURE")   # relative: relocatable
    Pkg.instantiate()
    Pkg.precompile(; strict=true)
    using OpenADMIXTURE   # SnpArrays is not a direct dependency of this environment
    for ext in ("bed", "bim", "fam")
        cp(OpenADMIXTURE.SnpArrays.datadir("EUR_subset.$ext"), joinpath("..", "testdata", "EUR_subset.$ext"))
    end
'
# Load once with the run-time settings so any cache the launcher needs is built now.
"$julia" --startup-file=no --project=. -t 2 -e 'using OpenADMIXTURE'

# 4. Drop what is not needed at run time (registry, git clones, logs).
rm -rf "$depot/registries" "$depot/clones" "$depot/logs"

# 5. Launcher
sed "s/@VERSION@/$PKG_VERSION-$PKG_BUILDNUM/" "$RECIPE_DIR/openadmixture.sh" > "$PREFIX/bin/openadmixture"
chmod +x "$PREFIX/bin/openadmixture"
