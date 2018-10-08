pushd gzstream
make clean
make CXX="$CXX $CXXFLAGS" CPPFLAGS="$CPPFLAGS -I. -I$PREFIX/include" AR="$AR cr"
popd
pushd src
make CXXFLAGS="$CXXFLAGS"
make install
popd
