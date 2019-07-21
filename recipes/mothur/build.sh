# the flags the new gxx activate script sets breaks the build, so unset them here
# unset CXXFLAGS
# export CXXFLAGS="-I${PREFIX}/include"

### Configuring settings within mothur Makefile
# Enabling dependencies for full functionality
sed -i 's;\(USEBOOST \?\=\) no;\1 yes;' Makefile
sed -i 's;\(USEHDF5 \?\=\) no;\1 yes;' Makefile
sed -i 's;\(USEGSL \?\=\) no;\1 yes;' Makefile
# Specifying dependency locations
sed -i 's;\(BOOST_LIBRARY_DIR \?\=\) \"\\\"Enter_your_boost_library_path_here\\\"\";\1 \"\\\"'"${PREFIX}"'\/lib\\\"\";' Makefile
sed -i 's;\(BOOST_INCLUDE_DIR \?\=\) \"\\\"Enter_your_boost_include_path_here\\\"\";\1 \"\\\"'"${PREFIX}"'\/include/boost\\\"\";' Makefile
sed -i 's;\(HDF5_LIBRARY_DIR \?\=\) \"\\\"Enter_your_HDF5_library_path_here\\\"\";\1 \"\\\"'"${PREFIX}"'\/lib\\\"\";' Makefile
sed -i 's;\(HDF5_INCLUDE_DIR \?\=\) \"\\\"Enter_your_HDF5_include_path_here\\\"\";\1 \"\\\"'"${PREFIX}"'\/include\\\"\";' Makefile
sed -i 's;\(GSL_LIBRARY_DIR \?\=\) \"\\\"Enter_your_GSL_library_path_here\\\"\";\1 \"\\\"'"${PREFIX}"'\/lib\\\"\";' Makefile
sed -i 's;\(GSL_INCLUDE_DIR \?\=\) \"\\\"Enter_your_GSL_include_path_here\\\"\";\1 \"\\\"'"${PREFIX}"'\/include/gsl\\\"\";' Makefile

### Reconfiguring compiler for uchime Makefile
sed -i 's/g++/$CXX/g' source/uchime_src/mk

### Compiling programs
make

### Cleaning up
make clean

# Copy executables to bin
cp {mothur,uchime} "${PREFIX}"/bin/

### Placing BLAST binaries in location required by mothur
mkdir -pv "${PREFIX}"/bin/blast/bin/
ln -s "${PREFIX}"/bin/{blastall,formatdb,megablast} "${PREFIX}"/bin/blast/bin/
