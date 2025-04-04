mkdir -pv $PREFIX/bin
make CC="${CXX}" LINKER="${CXX}" -j ${CPU_COUNT}
cp cdbfasta $PREFIX/bin
cp cdbyank $PREFIX/bin
