MAC=0
if [[ "$OSTYPE" == "darwin"* ]]; then
    MAC=1
fi

make GSL_PATH=$PREFIX/ CC=$CXX MAC=$MAC
make install BIN_INSTALL=$PREFIX/bin/ LIB_INSTALL=$PREFIX/lib/ MAC=$MAC
