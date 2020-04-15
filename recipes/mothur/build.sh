### Dumping preset flags because they break the build process on linux
# Linker flags
unset LDFLAGS
export LDFLAGS="-L${PREFIX}/lib"
# Compiler flags
unset CXXFLAGS
export CXXFLAGS="-I${PREFIX}/include"


### Configuring settings within mothur Makefile
# Enabling dependencies for full functionality
sed 's;\(USEBOOST ?\=\) no;\1 yes;' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
sed 's;\(USEHDF5 ?\=\) no;\1 yes;' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
sed 's;\(USEGSL ?\=\) no;\1 yes;' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
# Specifying dependency locations
sed 's;\(BOOST_LIBRARY_DIR ?\=\) \"\\\"Enter_your_boost_library_path_here\\\"\";\1 \"'"${PREFIX}"'\/lib/\";' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
sed 's;\(BOOST_INCLUDE_DIR ?\=\) \"\\\"Enter_your_boost_include_path_here\\\"\";\1 \"'"${PREFIX}"'\/include/boost/\";' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
sed 's;\(HDF5_LIBRARY_DIR ?\=\) \"\\\"Enter_your_HDF5_library_path_here\\\"\";\1 \"'"${PREFIX}"'\/lib/\";' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
sed 's;\(HDF5_INCLUDE_DIR ?\=\) \"\\\"Enter_your_HDF5_include_path_here\\\"\";\1 \"'"${PREFIX}"'\/include/\";' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
sed 's;\(GSL_LIBRARY_DIR ?\=\) \"\\\"Enter_your_GSL_library_path_here\\\"\";\1 \"'"${PREFIX}"'\/lib/\";' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
sed 's;\(GSL_INCLUDE_DIR ?\=\) \"\\\"Enter_your_GSL_include_path_here\\\"\";\1 \"'"${PREFIX}"'\/include/gsl/\";' Makefile > Makefile.tmp && mv Makefile.tmp Makefile


### Compiling mothur
make clean
make


### Compiling uchime
cd source/uchime_src && ./mk && mv uchime ../../ && cd ../../


### Organizing bin
# Copy mothur and uchime executables to bin
cp {mothur,uchime} "${PREFIX}"/bin/
# Linking BLAST binaries to default location for mothur
mkdir -pv "${PREFIX}"/bin/blast/bin/
ln -s "${PREFIX}"/bin/{blastall,formatdb,megablast} "${PREFIX}"/bin/blast/bin/
