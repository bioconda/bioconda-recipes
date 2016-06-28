# Depending on our platform, shared libraries end with either .so or .dylib
if [[ `uname` == 'Darwin' ]]; then
    DYLIB_EXT=dylib
else
    DYLIB_EXT=so
fi

# Build all CPU targets and allow dynamic configuration
# Build LAPACK.
# Set number of thread to 1; however, this can be changed by
# setting OPENBLAS_NUM_THREADS before loading the library.
make DYNAMIC_ARCH=1 BINARY=${ARCH} NO_LAPACK=0 NO_AFFINITY=1 NUM_THREADS=1 -j${CPU_COUNT}
make install PREFIX=$PREFIX

# Make sure the linked gfortran libraries are searched for on the RPATH.
if [[ `uname` == 'Darwin' ]]; then
    GFORTRAN_LIB=$(python -c "from os.path import realpath; print(realpath(\"$(gfortran -print-file-name=libgfortran.3.dylib)\"))")
    GCC_LIB=$(python -c "from os.path import realpath; print(realpath(\"$(gfortran -print-file-name=libgcc_s.1.dylib)\"))")
    QUADMATH_LIB=$(python -c "from os.path import realpath; print(realpath(\"$(gfortran -print-file-name=libquadmath.0.dylib)\"))")
    install_name_tool -change $GFORTRAN_LIB @rpath/libgfortran.3.dylib $PREFIX/lib/libopenblas.dylib
    install_name_tool -change $GCC_LIB @rpath/libgcc_s.1.dylib $PREFIX/lib/libopenblas.dylib
    install_name_tool -change $QUADMATH_LIB @rpath/libquadmath.0.dylib $PREFIX/lib/libopenblas.dylib
fi

# As OpenBLAS, now will have all symbols that BLAS or LAPACK have,
# create libraries with the standard names that are linked back to
# OpenBLAS. This will make it easier for packages that are looking for them.
ln -fs $PREFIX/lib/libopenblas.a $PREFIX/lib/libblas.a
ln -fs $PREFIX/lib/libopenblas.a $PREFIX/lib/liblapack.a
ln -fs $PREFIX/lib/libopenblas.$DYLIB_EXT $PREFIX/lib/libblas.$DYLIB_EXT
ln -fs $PREFIX/lib/libopenblas.$DYLIB_EXT $PREFIX/lib/liblapack.$DYLIB_EXT
