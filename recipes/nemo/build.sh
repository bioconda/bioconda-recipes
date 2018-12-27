if [[ "$OSTYPE" == "darwin"* ]]; then
    make GSL_PATH=$PREFIX/ CC=$CXX MAC=1
else
    make GSL_PATH=$PREFIX/ CC=$CXX
fi

make install BIN_INSTALL=$PREFIX/bin/ LIB_INSTALL=$PREFIX/lib/
