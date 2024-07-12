export HAS_GTEST=0
export LD_LIBRARY_PATH=${PREFIX}/lib
export STATIC=1

# fix build number in config
sed -i.bak 's/VERSION_STRING.*/VERSION_STRING="${PKG_VERSION}"/' config.mk

make CXX=$CXX CC=$CC CXXFLAGS="$CXXFLAGS" CFLAGS="$CFLAGS"
mkdir -p "${PREFIX}/bin"
mv build/release/dragen-os ${PREFIX}/bin/
