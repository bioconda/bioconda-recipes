mkdir -pv $PREFIX/bin
make CC="${CXX}" LINKER="${CXX}"
cp cdbfasta $PREFIX/bin
cp cdbyank $PREFIX/bin
