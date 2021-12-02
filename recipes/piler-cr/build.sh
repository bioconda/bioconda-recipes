make GPP=${CXX} CFLAGS="${CXXFLAGS}" LDLIBS="${LDFLAGS} -lm"

mkdir -p $PREFIX/bin
cp pilercr $PREFIX/bin/pilercr
