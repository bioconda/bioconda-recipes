#!/bin/bash

if [ $PY3K -eq 1 ]; then
    2to3 -w -n build/test/RBT_HOME/check_test.py
    #2to3 -w -n bin/sdrmsd
    #2to3 -w -n bin/sdtether
fi

mkdir biocondabuild
cd biocondabuild
meson --buildtype=release --prefix="$PREFIX" --backend=ninja -Dlibdir=lib ..
meson install

cd ..

#cp lib/libRbt.so.rDock_2013.1_src "${PREFIX}/lib/"
PERL_INSTALLSITELIB=$(perl -e 'use Config; print "$Config{installsitelib}"')

PERL5DIR=`(perl -e 'use Config; print $Config{archlibexp}, "\n";') 2>/dev/null`
echo $PERL5DIR
echo $PERL5LIB
echo $PERL_INSTALLSITELIB


mkdir -p "${PERL_INSTALLSITELIB}" "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin"

cp lib/*.pl lib/*.pm "${PERL_INSTALLSITELIB}"

mv data/ "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/"

# Create wrappers for binaries that need RBT_ROOT to be in the environment
for f in rbcalcgrid rbcavity rbdock rblist rbmoegrid; do
    mv "${PREFIX}/bin/$f" "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin/"
    sed -e "s|CHANGEME|${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}|" "$RECIPE_DIR/wrapper.sh" > "${PREFIX}/bin/$f"
    chmod +x "${PREFIX}/bin/$f"
done

# Remove unused to_unix
rm bin/to_unix
cp bin/* "${PREFIX}/bin/"

