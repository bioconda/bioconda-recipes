### Dumping preset flags because they break the build process on linux
# Linker flags
unset LDFLAGS
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
# Compiler flags
unset CXXFLAGS
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include -I."

### Compiling mothur
make clean
make -j"${CPU_COUNT}"
make install
cp -af uchime ${PREFIX}/bin

# Linking BLAST binaries to default location for mothur
mkdir -pv "${PREFIX}"/bin/blast/bin/
ln -sf "${PREFIX}"/bin/{blastall,formatdb,megablast} "${PREFIX}"/bin/blast/bin/
