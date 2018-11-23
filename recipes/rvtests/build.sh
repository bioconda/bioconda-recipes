# export these flags so that zlib.h can be found
export CFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

# Build
make

# Install
mkdir -p $PREFIX/bin
cp executable/rvtests $PREFIX/bin
