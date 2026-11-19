#!/bin/bash
set -xe

# setup.py calls gcc and g++ by name and compiles with -march=native
ln -sf "${CC}" "${BUILD_PREFIX}/bin/gcc"
ln -sf "${CXX}" "${BUILD_PREFIX}/bin/g++"
sed -i 's/ *"-march=native",//' setup.py
# haddock-restraints comes from the second source, not from a download
sed -i 's/^        self\.download_binaries()$/        pass/' setup.py

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv

install -m 755 haddock-restraints/haddock-restraints "${SP_DIR}/haddock/bin/haddock-restraints"
