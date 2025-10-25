#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-template-body -Wno-maybe-uninitialized -Wno-non-pod-varargs"

mkdir -p biocondabuild
cd biocondabuild

if [[ "$(uname -s)" == "Linux" ]]; then
	sed -i "10a [provide]" ../subprojects/cxxopts.wrap
	sed -i "11a cxxopts = cxxopts_dep " ../subprojects/cxxopts.wrap
fi

meson --buildtype=release --prefix="$PREFIX" --backend=ninja -Dlibdir=lib --strip ..

if [[ "$(uname -s)" == "Linux" ]]; then
	sed -i "27a #include <cstdint>" ../subprojects/cxxopts-2.2.1/include/cxxopts.hpp
fi

ninja install -j"${CPU_COUNT}"

cd ..

#cp lib/libRbt.so.rDock_2013.1_src "${PREFIX}/lib/"
PERL_INSTALLSITELIB=$(perl -e 'use Config; print "$Config{installsitelib}"')

PERL5DIR=`(perl -e 'use Config; print $Config{archlibexp}, "\n";') 2>/dev/null`
echo $PERL5DIR
echo $PERL5LIB
echo $PERL_INSTALLSITELIB


mkdir -p "${PERL_INSTALLSITELIB}" "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin"

cp -f lib/*.pl lib/*.pm "${PERL_INSTALLSITELIB}"

mv data/ "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/"
cp -f biocondabuild/subprojects/fmt-7.0.1/libfmt.so ${PREFIX}/lib

# Create wrappers for binaries that need RBT_ROOT to be in the environment

if [[ "$(uname -s)" == "Linux" ]]; then
	for f in rbcalcgrid  rbconvgrid  rblist  rbmoegrid  rbrms; do
            mv "${PREFIX}/bin/$f" "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin/"
            sed -e "s|CHANGEME|${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}|" "$RECIPE_DIR/wrapper.sh" > "${PREFIX}/bin/$f"
            chmod +x "${PREFIX}/bin/$f"
        done
else
	for f in rbcalcgrid rbcavity rbdock rblist rbmoegrid; do
	    mv "${PREFIX}/bin/$f" "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin/"
	    sed -e "s|CHANGEME|${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}|" "$RECIPE_DIR/wrapper.sh" > "${PREFIX}/bin/$f"
	    chmod +x "${PREFIX}/bin/$f"
	done
fi

# Remove unused to_unix
rm -rf bin/to_unix
install -v -m 0755 bin/* "${PREFIX}/bin"
