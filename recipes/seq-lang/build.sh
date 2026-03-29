#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

export INSTALLDIR="${PWD}/deps"
export SRCDIR="${PWD}/deps_src"
mkdir -p "${INSTALLDIR}" "${SRCDIR}"


export JOBS=1
if [ -n "${1}" ]; then export JOBS="${1}"; fi
echo "Using ${JOBS} cores..."

# Tapir
TAPIR_LLVM_BRANCH='release_60-release'
if [ ! -d "${SRCDIR}/Tapir-LLVM" ]; then
  git clone --depth 1 -b "${TAPIR_LLVM_BRANCH}" https://github.com/seq-lang/Tapir-LLVM "${SRCDIR}/Tapir-LLVM"
fi
if [ ! -f "${INSTALLDIR}/bin/llc" ]; then
  mkdir -p "${SRCDIR}/Tapir-LLVM/build"
  cd "${SRCDIR}/Tapir-LLVM/build"
  cmake .. \
     -DLLVM_INCLUDE_TESTS=OFF \
     -DLLVM_ENABLE_RTTI=ON \
     -DCMAKE_BUILD_TYPE=Release \
     -DLLVM_TARGETS_TO_BUILD=host \
     -DLLVM_ENABLE_ZLIB=OFF \
     -DLLVM_ENABLE_TERMINFO=OFF \
     -DCMAKE_C_COMPILER="${CC}" \
     -DCMAKE_CXX_COMPILER="${CXX}" \
     -DCMAKE_INSTALL_PREFIX="${INSTALLDIR}"
  make -j "${JOBS}"
  make install
  "${INSTALLDIR}/bin/llvm-config" --cmakedir
fi

# Menhir
MENHIR_VERSION='20190924'
if [ ! -d "${SRCDIR}/menhir-${MENHIR_VERSION}" ]; then
  curl -L "https://gitlab.inria.fr/fpottier/menhir/-/archive/${MENHIR_VERSION}/menhir-${MENHIR_VERSION}.tar.gz" | tar zxf - -C "${SRCDIR}"
fi
cd "${SRCDIR}/menhir-${MENHIR_VERSION}"
make PREFIX="${INSTALLDIR}" all -j "${JOBS}"
make PREFIX="${INSTALLDIR}" install
"${INSTALLDIR}/bin/menhir" --version
[ ! -f "${INSTALLDIR}/share/menhir/menhirLib.cmx" ] && die "Menhir library not found"

mkdir build
cd build 
cmake .. -DCMAKE_BUILD_TYPE=Release \
                      -DSEQ_DEP=../deps \
                      -DCMAKE_C_COMPILER=${CC} \
                      -DCMAKE_CXX_COMPILER=${CXX}

cmake --build build --config Release
