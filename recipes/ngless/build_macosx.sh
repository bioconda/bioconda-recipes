#!/usr/bin/env bash


set -e -o pipefail -x



#######################################################################################################
# Set up build environment
#######################################################################################################

mkdir -p $PREFIX/bin $BUILD_PREFIX/bin $PREFIX/lib $BUILD_PREFIX/lib $PREFIX/share $BUILD_PREFIX/share
export LIBRARY_PATH="${PREFIX}/lib:${LIBRARY_PATH}"
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"
export LDFLAGS=" -L${PREFIX}/lib ${LDFLAGS} "
export CPPFLAGS="-I${PREFIX}/include ${CPPFLAGS} "
export CFLAGS="-I${PREFIX}/include ${CFLAGS} "


#
# Install shim scripts to ensure that certain flags are always passed to the compiler/linker
#

echo "#!/bin/bash" > $CC-shim
echo "set -e -o pipefail -x " >> $CC-shim
echo "$CC -I$PREFIX/include -L$PREFIX/lib -pthread -fPIC \"\$@\"" >> $CC-shim
chmod u+x $CC-shim
export CC=$CC-shim

echo "#!/bin/bash" > $GCC-shim
echo "set -e -o pipefail -x " >> $GCC-shim
echo "$GCC -I$PREFIX/include -L$PREFIX/lib -pthread -fPIC \"\$@\"" >> $GCC-shim
chmod u+x $GCC-shim
export GCC=$GCC-shim

echo "#!/bin/bash" > $CXX-shim
echo "set -e -o pipefail -x " >> $CXX-shim
echo "$CXX -I$PREFIX/include -L$PREFIX/lib -pthread -fPIC \"\$@\"" >> $CXX-shim
chmod u+x $CXX-shim
export CXX=$CXX-shim

echo "#!/bin/bash" > $LD-shim
echo "set -e -o pipefail -x " >> $LD-shim
echo "$LD -L$PREFIX/lib \"\$@\"" >> $LD-shim
chmod u+x $LD-shim
export LD=$LD-shim

echo "#!/bin/bash" > ${LD}.gold
echo "set -e -o pipefail -x " >> ${LD}.gold
echo "$LD_GOLD -L$PREFIX/lib \"\$@\"" >> ${LD}.gold
chmod u+x ${LD}.gold
export LD_GOLD=${LD}.gold

#######################################################################################################
# Install GHC
#######################################################################################################

export GHC_PREFIX=${SRC_DIR}/ghc_pfx
mkdir -p $GHC_PREFIX/bin
export PATH=$PATH:${GHC_PREFIX}/bin

pushd ${SRC_DIR}/ghc
./configure --prefix=${GHC_PREFIX}
make install
ghc-pkg recache

popd


#######################################################################################################
# Build NGLess
#######################################################################################################

pushd ${SRC_DIR}/ngless

export STACK_ROOT=${SRC_DIR}/stack_root
mkdir -p $STACK_ROOT
(
    echo "extra-include-dirs:"
    echo "- ${PREFIX}/include"
    echo "extra-lib-dirs:"
    echo "- ${PREFIX}/lib"
    echo "ghc-options:"
    echo "  \"\$everything\": -optc-I${PREFIX}/include -optl-L${PREFIX}/lib"
    echo "apply-ghc-options: everything"
    echo "system-ghc: true"
) > "${STACK_ROOT}/config.yaml"

stack setup
stack update
make NGLess/Dependencies/Versions.hs
make external-deps CC=$CC CXX=$GCC
stack build --extra-include-dirs ${PREFIX}/include --extra-lib-dirs ${PREFIX}/lib --local-bin-path ${PREFIX}/bin

make install WGET="wget --no-check-certificate" prefix=$PREFIX CC=$CC

rm -r .stack-work
popd
