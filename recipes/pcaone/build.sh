#!/usr/bin/env bash

mkdir -p ${PREFIX}/bin
echo "
######################### configure ################
# conda install -c forge mkl
# make sure libiomp5 can be found
MKLROOT       =
# by default dynamical linking
STATIC       := 0
# only if static = 1, IOMP5 works
IOMP5        := 1

########################### end ###########################

VERSION=0.1.7
# detect OS architecture and add flags
Platform     := $(shell uname -s)

$(info "building PCAone on ${Platform} -- version ${VERSION}")

####### INC, LPATHS, LIBS, MYFLAGS
program       = PCAone
# for mac user, please change this to gnu gcc instead of the default clang version
# brew install gcc && ln -s $(which g++-11) /usr/local/bin/g++
# use default g++ only if not set in env
CXX          ?= g++
CXXFLAGS	    = -O3 -Wall -std=c++11 -march=native -ffast-math -m64 -fPIC -pipe
MYFLAGS       = -DVERSION=\"$(VERSION)\" -DNDEBUG
LINKFLAGS     = -s
CFLAGS        =
# CURRENT_DIR   = $(shell pwd)
INC           = -I./external -I./external/zstd/lib
AVX           = 1

ifeq ($(strip $(AVX)),1)
  $(info "use -mavx2 for PCAone")
  CXXFLAGS += -mavx2 -mfma
endif

MYFLAGS += -DWITH_MKL -DEIGEN_USE_MKL_ALL -fopenmp
INC     += -I${MKLROOT}/include/
LPATHS  += -L${MKLROOT}/lib
DLIBS   += -Wl,-rpath,${MKLROOT}/lib -lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core -liomp5 -lpthread 
DLIBS   += -lz -lzstd

OBJ = $(patsubst %.cpp, %.o, $(wildcard ./src/*.cpp))

SLIBS += ./external/bgen/bgenlib.a

LIBS += ${SLIBS} ${DLIBS} -lm -ldl

.PHONY: clean

all: ${program}

${program}: zstdlib bgenlib ${OBJ}
	$(CXX) $(CXXFLAGS) $(CFLAGS) $(LINKFLAGS) -o $(program) ${OBJ}  ${LPATHS} ${LIBS}

%.o: %.cpp
	${CXX} ${CXXFLAGS} ${MYFLAGS} -o $@ -c $< ${INC}

zstdlib:
ifeq ($(STATIC),1)
	(cd ./external/zstd/lib/; $(MAKE))
else
	@echo "no building zstd manually"
endif

bgenlib:
	(cd ./external/bgen/; $(MAKE))

rm:
	(rm -f $(OBJ) $(program))
	(cd ./external/bgen/; $(MAKE) clean)

clean:
	(rm -f $(OBJ) $(program))
	(cd ./external/bgen/; $(MAKE) clean)
	(cd ./external/zstd/lib/; $(MAKE) clean)
" >conda.makefile
make -f conda.makefile MKLROOT=${PREFIX}
mv PCAone ${PREFIX}/bin/
