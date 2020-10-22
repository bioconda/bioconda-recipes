#!/bin/bash

if [ $PY3K -eq 1 ]; then
    2to3 -w -n build/test/RBT_HOME/check_test.py
fi
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

cd build/
make linux-g++-64
make test

cd ..
cp lib/libRbt.so.rDock_2013.1_src "${PREFIX}/lib/"
PERL_INSTALLSITELIB=$(perl -e 'use Config; print "$Config{installsitelib}"')
mkdir -p "${PERL_INSTALLSITELIB}" "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin"
cp lib/*.pl lib/*.pm "${PERL_INSTALLSITELIB}"
mv data/ "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/"
# Create wrappers for binaries that need RBT_ROOT to be in the environment
for f in rbcalcgrid rbcavity rbdock rblist rbmoegrid; do
    mv "bin/$f" "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin/"
    sed -e "s|CHANGEME|${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}|" "$RECIPE_DIR/wrapper.sh" > "${PREFIX}/bin/$f"
    chmod +x "${PREFIX}/bin/$f"
done
# Remove unused to_unix
rm bin/to_unix
cp bin/* "${PREFIX}/bin/"
