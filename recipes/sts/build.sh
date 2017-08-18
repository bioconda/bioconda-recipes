git submodule update --init
make
mkdir -p $PREFIX/bin
cp _build/release/bin/sts-online $PREFIX/bin
