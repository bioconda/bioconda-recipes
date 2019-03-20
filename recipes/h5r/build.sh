HDF5_HOME="$PREFIX/lib"
R CMD INSTALL --configure-args="--with-hdf5=$HDF5_HOME" .
