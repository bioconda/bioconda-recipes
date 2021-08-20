export HAS_GTEST=0

make
make install
mkdir -p "${PREFIX}/bin"
mv build/release/dragen-os ${PREFIX}/bin/
