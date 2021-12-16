#!/bin/bash
set +ex
export USE_CYTHON=True
export PERFORMING_CONDA_BUILD=True
export LIBRARY_PATH="${CONDA_PREFIX}/lib"
export LD_LIBRARY_PATH=${LIBRARY_PATH}:${LD_LIBRARY_PATH}
export CPLUS_INCLUDE_PATH="${CONDA_PREFIX}/include"

echo "==== Native compiler versions ===="
if [[ "$(uname -s)" == "Linux" ]];
then
  which x86_64-conda-linux-gnu-gcc
  x86_64-conda-linux-gnu-gcc -v
  x86_64-conda-linux-gnu-g++ -v
else
  which clang
  clang -v
fi

if [[ "$(uname -s)" == "Linux" ]];
then
   #
   # This is a helper script for installing the NVIDIA HPC SDK 
   # needed to compile a GPU-enabled version of unifrac.
   #

   # Create GCC symbolic links
   # since NVIDIA HPC SDK does not use the env variables

   ls -l $BUILD_PREFIX/bin/x86_64-conda_cos6-linux-gnu-*

   for f in \
     ar as c++ cc cpp g++ gcc ld nm ranlib strip; \
     do \
       ln -s $BUILD_PREFIX/bin/x86_64-conda_cos6-linux-gnu-${f} $BUILD_PREFIX/bin/${f}; \
     done 

   which gcc
   gcc -v
   g++ -v

   # Install the NVIDIA HPC SDK

   curl https://developer.download.nvidia.com/hpc-sdk/20.9/nvhpc_2020_209_Linux_x86_64_cuda_11.0.tar.gz | tar xpzf -

   # must patch the  install scripts to find the right gcc
   for f in nvhpc_*/install_components/install nvhpc_*/install_components/*/*/compilers/bin/makelocalrc nvhpc_*/install_components/install_cuda; do
     sed -i -e "s#PATH=/#PATH=$BUILD_PREFIX/bin:/#g" $f
   done

   export NVHPC_INSTALL_DIR=$BUILD_PREFIX/hpc_sdk
   export NVHPC_SILENT=true
   echo "Installing NVIDIA HPC SDK in ${NVHPC_INSTALL_DIR}"

   (cd nvhpc_*; ./install)

   for f in $NVHPC_INSTALL_DIR/*/202*/compilers/bin; do
     export PATH=$f:$PATH
   done

   # pgc++ does not define it, but gcc libraries expect it
   # also remove the existing conda flags, which are not compatible
   export CPPFLAGS=-D__GCC_ATOMIC_TEST_AND_SET_TRUEVAL=0
   export CXXFLAGS=${CPPFLAGS}
   export CFLAGS=${CPPFLAGS}

   # we will not bother with debug flags, just remove
   unset DEBUG_CPPFLAGS
   unset DEBUG_CXXFLAGS
   unset DEBUG_CFLAGS

   # h5c++ patch
   cp $BUILD_PREFIX/bin/h5c++ $BUILD_PREFIX/bin/h5c++.org

   echo 'Org grep FLAGS= $BUILD_PREFIX/bin/h5c++'
   grep FLAGS= $BUILD_PREFIX/bin/h5c++

   # This works on linux with gcc ..
   sed -i \
     "s#x86_64-conda.*-linux-gnu-c++#pgc++ -I`ls -d $NVHPC_INSTALL_DIR/*/202*/compilers/include`#g" \
     $BUILD_PREFIX/bin/h5c++ 
   sed -i \
     's#H5BLD_CXXFLAGS=".*"#H5BLD_CXXFLAGS=" -fvisibility-inlines-hidden -std=c++17 -fPIC -O2 -I${includedir}"#g'  \
     $BUILD_PREFIX/bin/h5c++
   sed -i \
     's#H5BLD_CPPFLAGS=".*"#H5BLD_CPPFLAGS=" -I${includedir} -DNDEBUG -D_FORTIFY_SOURCE=2 -O2"#g' \
     $BUILD_PREFIX/bin/h5c++
   sed -i \
     's#H5BLD_LDFLAGS=".*"#H5BLD_LDFLAGS=" -L$BUILD_PREFIX/x86_64-conda-linux-gnu/sysroot/usr/lib64/ -L${libdir} -Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,--disable-new-dtags -Wl,-rpath,$BUILD_PREFIX/x86_64-conda-linux-gnu/sysroot/usr/lib64/ -Wl,-rpath,$BUILD_PREFIX/lib -Wl,-rpath,$BUILD_PREFIX/x86_64-conda-linux-gnu/sysroot/usr/lib64/ -Wl,-rpath,${libdir}"#g' \
     $BUILD_PREFIX/bin/h5c++

   echo 'Patched grep FLAGS= $BUILD_PREFIX/bin/h5c++'
   grep FLAGS= $BUILD_PREFIX/bin/h5c++

   echo 'ls -l $PREFIX/x86_64-conda-linux-gnu/sysroot/usr/lib64/crt*'
   ls -l $PREFIX/x86_64-conda-linux-gnu/sysroot/usr/lib64/crt*
   echo 'ls -l $BUILD_PREFIX/x86_64-conda-linux-gnu/sysroot/usr/lib64/crt*'
   ls -l $BUILD_PREFIX/x86_64-conda-linux-gnu/sysroot/usr/lib64/crt*

   # patch localrc to find crt1.o
   for f in ${NVHPC_INSTALL_DIR}/*/202*/compilers/bin/localrc; do
    echo "set DEFSTDOBJDIR=$BUILD_PREFIX/x86_64-conda-linux-gnu/sysroot/usr/lib64;" >> $f
    echo "====localrc $f ===="
    cat $f
    echo "===="
   done

   # Here lapacke is needed on Linux, too
   sed -i 's/BLASLIB=-lcblas/BLASLIB=-llapacke -lcblas/g' sucpp/Makefile
fi

echo "==== Compiler version ===="
which h5c++
h5c++ --version

echo "==== Compiling ===="
pushd sucpp
make main
make api
make test
./test_su
popd

$PYTHON -m pip install --no-deps --ignore-installed .
rc=$?

if [[ "$(uname -s)" == "Linux" ]];
then
   # Final cleanup
   for f in \
     ar as c++ cc cpp g++ gcc ld nm ranlib strip; \
     do \
       rm -f $BUILD_PREFIX/bin/${f}; \
     done 

   cp $BUILD_PREFIX/bin/h5c++.org $BUILD_PREFIX/bin/h5c++
   rm -fr ${NVHPC_INSTALL_DIR}
fi

exit $rc

