#!/usr/bin/env bash


# This tour de force script is mostly copy&pasted from
# https://github.com/conda-forge/git-annex-feedstock

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

export GMP_INCLUDE_DIRS=$PREFIX/include
export GMP_LIB_DIRS=$PREFIX/lib

#
# Install shim scripts to ensure that certain flags are always passed to the compiler/linker
#

echo "#!/bin/bash" > $CC-shim
echo "set -e -o pipefail -x " >> $CC-shim
echo "$CC -I$PREFIX/include -L$PREFIX/lib -pthread -fPIC \"\$@\"" >> $CC-shim
chmod u+x $CC-shim
export CC=$CC-shim

if [ $(uname) != Darwin ]; then
echo "#!/bin/bash" > $GCC-shim
echo "set -e -o pipefail -x " >> $GCC-shim
echo "$GCC -I$PREFIX/include -L$PREFIX/lib -pthread -fPIC \"\$@\"" >> $GCC-shim
chmod u+x $GCC-shim
export GCC=$GCC-shim
fi


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

install_ghc_linux () {

#
# Hack: ensure that the correct libpthread is used.
# This fixes an issue specific to https://github.com/conda-forge/docker-images/tree/master/linux-anvil-comp7
# which I do not fully understand, but the fix seems to work.
# See https://github.com/conda/conda/issues/8380
#

HOST_LIBPTHREAD="${BUILD_PREFIX}/${HOST}/sysroot/usr/lib/libpthread.so"

if [[ -f "${HOST_LIBPTHREAD}" ]]; then
    rm ${HOST_LIBPTHREAD}
    ln -s /lib64/libpthread.so.0 ${HOST_LIBPTHREAD}
fi


#######################################################################################################
# Install bootstrap ghc
#######################################################################################################

export GHC_BOOTSTRAP_PREFIX=${SRC_DIR}/ghc_bootstrap_pfx
mkdir -p $GHC_BOOTSTRAP_PREFIX/bin
export PATH=$PATH:${GHC_BOOTSTRAP_PREFIX}/bin

pushd ${SRC_DIR}/ghc_bootstrap
./configure --prefix=${GHC_BOOTSTRAP_PREFIX}
make install
ghc-pkg recache

popd

#######################################################################################################
# Build recent ghc from source
#######################################################################################################

pushd ${SRC_DIR}/ghc_src

touch mk/build.mk
echo "BuildFlavour = quick" >> mk/build.mk
echo "libraries/integer-gmp_CONFIGURE_OPTS += --configure-option=--with-gmp-includes=$PREFIX/include" >> mk/build.mk
echo "libraries/integer-gmp_CONFIGURE_OPTS += --configure-option=--with-gmp-libraries=$PREFIX/lib" >> mk/build.mk
echo "STRIP_CMD = $STRIP" >> build.mk

./boot
./configure --prefix=${BUILD_PREFIX}  --with-gmp-includes=$PREFIX/include --with-gmp-libraries=$PREFIX/lib --with-system-libffi
set +e
make -j${CPU_COUNT}
set -e
make
make install
ghc-pkg recache
ghc --version
popd
}

install_ghc_osx () {

export GHC_PREFIX=${SRC_DIR}/ghc_pfx
mkdir -p $GHC_PREFIX/bin
export PATH=$PATH:${GHC_PREFIX}/bin

pushd ${SRC_DIR}/ghc
./configure --prefix=${GHC_PREFIX}
make install
ghc-pkg recache

popd
}

if [ $(uname) == Darwin ]; then
    install_ghc_osx
else
    install_ghc_linux
fi


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
make external-deps CC=$CC CXX=$CXX
stack build --extra-include-dirs ${PREFIX}/include --extra-lib-dirs ${PREFIX}/lib --local-bin-path ${PREFIX}/bin

make install WGET="wget --no-check-certificate" prefix=$PREFIX CC=$CC

rm -r .stack-work
popd
