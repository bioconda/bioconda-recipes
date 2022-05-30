#!/usr/bin/env bash

mkdir -p ${PREFIX}/bin
# fix zlib issue
export CFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

echo '
######################### configure ################
# conda install -c forge mkl
MKLROOT       =
AVX           = 1

# detect OS architecture and add flags
Platform     := $(shell uname -s)
$(info "building PCAone on ${Platform} -- version ${VERSION}")
####### INC, LPATHS, LIBS, MYFLAGS
program       = PCAone
CXX          ?= g++
CXXFLAGS            = -O3 -Wall -std=c++11 -ffast-math -m64 -fPIC -pipe
MYFLAGS       = -DVERSION=\"$(VERSION)\" -DNDEBUG
LINKFLAGS     = -s
CFLAGS        =
# CURRENT_DIR   = $(shell pwd)
INC           = -I./external -I./external/zstd/lib
PCALIB        = libpcaone.a

ifeq ($(strip $(AVX)),1)
  $(info "use -mavx2 for PCAone")
  CXXFLAGS += -mavx2 -mfma
endif

MYFLAGS += -DWITH_MKL -DEIGEN_USE_MKL_ALL -fopenmp
INC     += -I${MKLROOT}/include/
LPATHS  += -L${MKLROOT}/lib
DLIBS   += -Wl,-rpath,${MKLROOT}/lib -lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core -liomp5 -lpthread
DLIBS   += -lz -lzstd

OBJ = src/Arnoldi.o src/Halko.o src/Data.o src/Utils.o \
                    src/FileBeagle.o src/FileCsv.o src/FileBgen.o src/FilePlink.o

SLIBS += ./external/zstd/lib/libzstd.a ./external/bgen/bgenlib.a

LIBS += ${SLIBS} ${DLIBS} -lm -ldl

.PHONY: clean

all: ${program}

${program}: zstdlib bgenlib pcaonelib src/Main.o
\t$(CXX) $(CXXFLAGS) $(CFLAGS) $(LINKFLAGS) -o $(program) src/Main.o ${PCALIB} ${LPATHS} ${LIBS} ${LDFLAGS}

%.o: %.cpp
\t${CXX} ${CXXFLAGS} ${MYFLAGS} -o $@ -c $< ${INC}

zstdlib:
\t(cd ./external/zstd/lib/; $(MAKE))

bgenlib:
\t(cd ./external/bgen/; $(MAKE))

pcaonelib:$(OBJ)
\tar -rcs $(PCALIB) $(OBJ)

rm:
\t(rm -f src/*.o $(program))
\t(cd ./external/bgen/; $(MAKE) clean)

clean:
\t(rm -f src/*.o $(program))
\t(cd ./external/bgen/; $(MAKE) clean)
\t(cd ./external/zstd/lib/; $(MAKE) clean)
' >Makefile

if [ $(uname -s) == "Linux" ];then
  make clean && make MKLROOT=${PREFIX} AVX=0 && mv PCAone ${PREFIX}/bin/PCAone.x64
  make clean && make MKLROOT=${PREFIX} AVX=1 && mv PCAone ${PREFIX}/bin/PCAone.avx2
  echo "#!/usr/bin/env bash
PCAone=${PREFIX}/bin/PCAone.avx2
grep avx2 /proc/cpuinfo |grep fma &>/dev/null
[[ \$? != 0 ]] && PCAone=${PREFIX}/bin/PCAone.x64
exec \$PCAone \$@" >${PREFIX}/bin/PCAone && chmod +x ${PREFIX}/bin/PCAone

elif [ $(uname -s) == "Darwin" ];then
  make MKLROOT=${PREFIX}
  mv PCAone ${PREFIX}/bin/
fi
