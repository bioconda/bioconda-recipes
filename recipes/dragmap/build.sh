export HAS_GTEST=0

# fix build number in config
sed -i.bak 's/VERSION_STRING.*/VERSION_STRING="${PKG_VERSION}"/' config.mk

# unset compilers
sed -i.bak 's/CXX=g++//' config.mk
sed -i.bak 's/CC=gcc//' config.mk

make CXX=$CXX CC=$CC
mkdir -p "${PREFIX}/bin"
mv build/release/dragen-os ${PREFIX}/bin/
