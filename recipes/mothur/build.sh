# the flags the new gxx activate script sets breaks the build, so unset them here
# unset CXXFLAGS
# export CXXFLAGS="-I${PREFIX}/include"

### Configuring settings within mothur Makefile
# Enabling dependencies for full functionality
sed 's;\(USEBOOST \?\=\) no;\1 yes;' Makefile
sed 's;\(USEHDF5 \?\=\) no;\1 yes;' Makefile
sed 's;\(USEGSL \?\=\) no;\1 yes;' Makefile
# Specifying dependency locations
sed 's;\(BOOST_LIBRARY_DIR \?\=\) \"\\\"Enter_your_boost_library_path_here\\\"\";\1 \"\\\"'"${PREFIX}"'\/lib\\\"\";' Makefile
sed 's;\(BOOST_INCLUDE_DIR \?\=\) \"\\\"Enter_your_boost_include_path_here\\\"\";\1 \"\\\"'"${PREFIX}"'\/include/boost\\\"\";' Makefile
sed 's;\(HDF5_LIBRARY_DIR \?\=\) \"\\\"Enter_your_HDF5_library_path_here\\\"\";\1 \"\\\"'"${PREFIX}"'\/lib\\\"\";' Makefile
sed 's;\(HDF5_INCLUDE_DIR \?\=\) \"\\\"Enter_your_HDF5_include_path_here\\\"\";\1 \"\\\"'"${PREFIX}"'\/include\\\"\";' Makefile
sed 's;\(GSL_LIBRARY_DIR \?\=\) \"\\\"Enter_your_GSL_library_path_here\\\"\";\1 \"\\\"'"${PREFIX}"'\/lib\\\"\";' Makefile
sed 's;\(GSL_INCLUDE_DIR \?\=\) \"\\\"Enter_your_GSL_include_path_here\\\"\";\1 \"\\\"'"${PREFIX}"'\/include/gsl\\\"\";' Makefile







mkdir -pv "${PREFIX}"/bin/blast/bin
sed -i 's/g++/$CXX/g' source/uchime_src/mk
make -j 2
cp {mothur,uchime} $PREFIX/bin
ln -s $PREFIX/bin/{bl2seq,formatdb,blastall,megablast} $PREFIX/bin/blast/bin/
