# "version" file is picked up as a c++ header file.
mv version{,.txt}
mv src/gzstream/version{,.txt}

./bootstrap
autoreconf -fi
./configure --prefix="${PREFIX}"
make DEPLOIDVERSION=''
make unit_tests
DYLD_LIBRARY_PATH=${PREFIX}/lib:${DYLD_LIBRARY_PATH} ./unit_tests
make install
