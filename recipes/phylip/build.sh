#!/bin/bash

## The build file is taken from the biobuilds conda recipe by Cheng
## H. Lee, adjusted to fit the bioconda format.

# Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

# Additional flags suggested by the philip makefile
CFLAGS="${CFLAGS} -fomit-frame-pointer -DUNX"

BUILD_ARCH=$(uname -m)
BUILD_OS=$(uname -s)

if [ "$BUILD_ARCH" == "ppc64le" ]; then
    # Just in case; make the same assumptions about plain "char" declarations
    # on little-endian POWER8 as we do on x86_64.
    CFLAGS="${CFLAGS} -fsigned-char"
fi

# Build
cd src
sed -i.bak "s:@@prefix@@:${PREFIX}:" phylip.h
if [ "$BUILD_OS" == "Darwin" ]; then
    # Tweak a few things for building shared libraries on OS X.
    sed -i.bak 's/-Wl,-soname/-Wl,-install_name/g' Makefile.unx
    sed -i.bak 's/\.so/.dylib/g' Makefile.unx
fi
make -f Makefile.unx CFLAGS="$CFLAGS" install

# Install
cd ..
SHARE_DIR="${PREFIX}/share/${PKG_NAME}-$PKG_VERSION-$PKG_BUILDNUM"
for d in fonts java exe; do
    install -d "${SHARE_DIR}/${d}"
    install ${d}/* "${SHARE_DIR}/${d}"
done
pushd "${SHARE_DIR}/java"
rm -f *.unx
popd

# Install wrapper scripts
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"
ln -s $SHARE_DIR/exe/* $PREFIX/bin/
# phylip's java interface can't find its dylibs (libtreegram.so,
# libdrawtree.dylib) Easiest, but oh so inelegant, solution was to
# link them to $PREFIX/bin
ln -s $SHARE_DIR/java/* $PREFIX/bin/

cp $RECIPE_DIR/phylip.py $PREFIX/bin/phylip

cp $RECIPE_DIR/drawtree.py $SHARE_DIR/drawtree_gui
ln -s $SHARE_DIR/drawtree_gui $PREFIX/bin

cp $RECIPE_DIR/drawgram.py $SHARE_DIR/drawgram_gui
ln -s $SHARE_DIR/drawgram_gui $PREFIX/bin

cd "${PREFIX}/bin"
chmod 0755 phylip drawgram drawtree drawgram_gui drawtree_gui

ls $PREFIX/bin
