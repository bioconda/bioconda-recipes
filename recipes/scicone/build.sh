#!/bin/bash
set -euxo pipefail

# ---------------------------------------------------------------------------
# C++ executables
# ---------------------------------------------------------------------------
cmake -S scicone -B build \
    ${CMAKE_ARGS:-} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}"

cmake --build build -j "${CPU_COUNT}"

# The unit tests resolve their input data relative to the source tree, so this
# is the only place they can run: by the time the test phase runs, the source
# is gone. The argument disables the (slow) reproducibility test.
./build/scicone-tests 0

cmake --install build

# ---------------------------------------------------------------------------
# Python package
# ---------------------------------------------------------------------------
# The source tree carries prebuilt binaries for people installing with pip.
# This package uses the ones just built into $PREFIX/bin, so drop them rather
# than vendoring a second, foreign copy into site-packages. A stale setuptools
# build/ directory would put them back, so that goes too.
rm -rf pyscicone/scicone/bin pyscicone/build pyscicone/scicone.egg-info

cd pyscicone
$PYTHON -m pip install . --no-deps --no-build-isolation -vv
cd ..

# Vendored binaries have slipped through before: they are several megabytes of
# executables built somewhere else, and one stale directory is enough to bring
# them back. Fail the build rather than ship them.
# Located without importing the package: its dependencies are run-time only and
# are not present in the build environment.
site_packages=$($PYTHON -c "import sysconfig; print(sysconfig.get_paths()['purelib'])")
vendored="${site_packages}/scicone/bin"
if [ -e "${vendored}" ]; then
    echo "ERROR: prebuilt binaries were vendored into the Python package:" >&2
    ls -la "${vendored}" >&2
    exit 1
fi
