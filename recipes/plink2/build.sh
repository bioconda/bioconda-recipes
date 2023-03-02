# Build plink2 from source
# Apparently this source bundle contains both 1.9 and 2.0.
# Per repo instructions, actual target Makefile is ./build_dynamic/Makefile.
# Due to how the Makefile includes dependent Makefiles, cwd has to be the build directory.
cd 2.0/build_dynamic

PLINK2_INCLUDES="-I${SRC_DIR}/2.0/libdeflate -I${SRC_DIR}/2.0/zstd/lib -I${SRC_DIR}/2.0/simde"
PLINK2_CFLAGS="-O2 -std=gnu99 -I${PREFIX}/include ${PLINK2_INCLUDES}"
PLINK2_CXXFLAGS="-O2 -std=c++11 -I${PREFIX}/include ${PLINK2_INCLUDES}"
PLINK2_LINKFLAGS="-L${PREFIX}/lib -lpthread -lm -lz"
make -f Makefile CC="${CC}" CXX="${CXX}" CFLAGS="${PLINK2_CFLAGS}" CXXFLAGS="${PLINK2_CXXFLAGS}" LINKFLAGS="${PLINK2_LINKFLAGS}" DYNAMIC_MKL="1" MKLROOT="${PREFIX}/lib" MKL_IOMP5_DIR="${PREFIX}/lib" CPU_CHECK=""

# Install as plink2
mkdir -p $PREFIX/bin
cp plink2 $PREFIX/bin/plink2
