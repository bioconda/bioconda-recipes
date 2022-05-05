#!/usr/bin/env bash

mkdir -p "${PREFIX}"/bin

export CXXPATH=${PREFIX}/include

make INCLUDES="-I$PREFIX/include" CXXFLAG="-g -Wall -O2 -std=c++11" 

OSTYPE=$(shell echo `uname`)
MACHINETYPE=$(shell echo `uname -m`)

ifeq(${MACHINETYPE}, x86_64)
  MACHINETYPE=amd64
endif

ifeq(${MACHINETYPE}, Power Macintosh)
  MACHINETYPE=ppc
endif

ifeq(${OSTYPE}, SunOS)
  MACHINETYPE=${shell echo `uname -p`}
  ifeq(${MACHINETYPE}, sparc)
    ifeq (${shell /usr/bin/isainfo -b}, 64)
      MACHINETYPE=sparc64
    else
      MACHINETYPE=sparc32
    endif
  endif
endif

cp $(PREFIX)/$(OSTYPE)-$(MACHINETYPE)/bin/Fec $(PREFIX)/bin/Fec
