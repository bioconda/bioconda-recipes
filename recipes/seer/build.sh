pushd gzstream
make clean
make CXX="$CXX $CXXFLAGS" CPPFLAGS="$CPPFLAGS -I. -I$PREFIX/include" AR="$AR cr"
popd
pushd boost
python2 tools/boostdep/depinst/depinst.py program_options --include example
./bootstrap.sh --with-libraries=program_options
./b2 install toolset=gcc
popd
pushd src
make CXXFLAGS="$CXXFLAGS"
make install
popd
