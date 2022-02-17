### Dumping preset flags because they break the build process on linux
# Linker flags
unset LDFLAGS
export LDFLAGS="-L${PREFIX}/lib"
# Compiler flags
unset CXXFLAGS
export CXXFLAGS="-I${PREFIX}/include -I."


### Compiling mothur
make clean
make -j 4
make install
cp -a uchime ${PREFIX}/bin

# Linking BLAST binaries to default location for mothur
mkdir -pv "${PREFIX}"/bin/blast/bin/
ln -s "${PREFIX}"/bin/{blastall,formatdb,megablast} "${PREFIX}"/bin/blast/bin/
