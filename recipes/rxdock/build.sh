#!/bin/bash

mkdir biocondabuild
cd biocondabuild
meson --buildtype=release --prefix="$PREFIX" --backend=ninja -Dlibdir=lib ..
meson install

cd ..

mkdir -p "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin"

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
