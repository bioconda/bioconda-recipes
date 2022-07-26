export HAS_GTEST=0

# fix build number in config
sed -i.bak 's/VERSION_STRING.*/VERSION_STRING="${PKG_VERSION}"/' config.mk

make CXX=$CXX CC=$CC CXXFLAGS="$CXXFLAGS" CFLAGS="$CFLAGS"
mkdir -p "${PREFIX}/bin"
mv build/release/dragen-os ${PREFIX}/bin/
