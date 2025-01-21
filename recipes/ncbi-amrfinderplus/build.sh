#!/bin/bash

echo "DEBUGGING environment info because PREFIX did not appear to be set"
echo "PREFIX=$PREFIX CONDA_PREFIX=$CONDA_PREFIX"
echo "PREFIX =" $PREFIX CONDA_PREFIX = $CONDA_PREFIX BUILD_PREFIX = $BUILD_PREFIX
echo $PREFIX

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# fix error because of gnu++17 features. Suggested by https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
CXXFLAGS="${CXXFLAGS} -O3 -D_LIBCPP_DISABLE_AVAILABILITY"

# Get StxTyper source as well
git submodule update --init

case $(uname -m) in
    aarch64 | arm64)
        CXXFLAGS="${CXXFLAGS} -fsigned-char"
        ;;
    *)
        ;;
esac

make CXX="$CXX $LDFLAGS" CPPFLAGS="$CXXFLAGS -I${PREFIX}/include" PREFIX="$PREFIX" DEFAULT_DB_DIR="${PREFIX}/share/amrfinderplus/data" -j"${CPU_COUNT}"

make install INSTALL_DIR="$PREFIX/bin"

### Temporary bug fix for issue with Makefile. These lines have been added to the makefile
# for future releases, so remove after version 4.0.3
if [ ! -e "$PREFIX/bin/stx/stxtyper" ]
then
    mkdir "$PREFIX/bin/stx"
    ln -s ../stxtyper "$PREFIX/bin/stx/stxtyper"
fi
# end bug fix
