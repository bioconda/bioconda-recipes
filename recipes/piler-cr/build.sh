make GPP=${CXX} CFLAGS="${CXXFLAGS} -std=c++14" LDLIBS="${LDFLAGS} -lm"

mkdir -p $PREFIX/bin
cp pilercr $PREFIX/bin/pilercr
