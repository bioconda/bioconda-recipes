#!/usr/bin/env bash
set -euxo pipefail

# Install the Python package.
# --no-deps is standard in conda recipes because dependencies are handled by meta.yaml.
${PYTHON} -m pip install . --no-deps --no-build-isolation --ignore-installed -vv

# Directory for bundled executable helpers used internally by pantax_dbg.paths.
mkdir -p "${PREFIX}/libexec/pantax-dbg"

# Build/copy modified ganon helper if the source tree contains it.
# The exact upstream layout may differ, so this section is intentionally defensive.
if [ -d "thirdparty/ganon_mod" ]; then
    pushd thirdparty/ganon_mod

    if [ -f "Makefile" ] || [ -f "makefile" ]; then
        make -j"${CPU_COUNT:-2}"
    elif [ -f "CMakeLists.txt" ]; then
        mkdir -p build
        cd build
        cmake ${CMAKE_ARGS:-} ..
        make -j"${CPU_COUNT:-2}"
        cd ..
    fi

    popd

    # Copy ganon executable(s), but do not assume one fixed build layout.
    while IFS= read -r exe; do
        cp -v "${exe}" "${PREFIX}/libexec/pantax-dbg/"
    done < <(
        find thirdparty/ganon_mod -type f \( -name "ganon" -o -name "ganon-build" -o -name "ganon-classify" -o -name "ganon-report" \) -perm -111 2>/dev/null | sort -u
    )
fi

# Build/copy DBG-ggcat helper if the source tree contains it.
if [ -d "thirdparty/ggcat_mod" ]; then
    pushd thirdparty/ggcat_mod

    if [ -f "Cargo.toml" ]; then
        cargo build --release
    elif [ -f "Makefile" ] || [ -f "makefile" ]; then
        make -j"${CPU_COUNT:-2}"
    elif [ -f "CMakeLists.txt" ]; then
        mkdir -p build
        cd build
        cmake ${CMAKE_ARGS:-} ..
        make -j"${CPU_COUNT:-2}"
        cd ..
    fi

    popd

    # Copy dbg-ggcat executable, allowing several possible build layouts.
    while IFS= read -r exe; do
        cp -v "${exe}" "${PREFIX}/libexec/pantax-dbg/dbg-ggcat"
        chmod 755 "${PREFIX}/libexec/pantax-dbg/dbg-ggcat"
        break
    done < <(
        find thirdparty/ggcat_mod -type f \( -name "dbg-ggcat" -o -name "ggcat" \) -perm -111 2>/dev/null | sort -u
    )
fi

# If the release tarball already ships helper executables under other common locations,
# copy them too. This keeps the recipe compatible with your previous release layout.
for exe in \
    "thirdparty/dbg-ggcat" \
    "thirdparty/ganon" \
    "dbg-ggcat" \
    "ganon"
do
    if [ -x "${exe}" ]; then
        cp -v "${exe}" "${PREFIX}/libexec/pantax-dbg/"
    fi
done

# Basic validation. Do NOT import the old internal name "themis" here.
${PYTHON} - <<'PY'
import importlib
for mod in ("pantax_dbg", "pantax_dbg_scripts"):
    importlib.import_module(mod)
print("PanTax-DBG python imports OK")
PY

pantax-dbg --help
fastp --version
