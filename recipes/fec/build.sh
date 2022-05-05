#!/usr/bin/env bash

mkdir -p "${PREFIX}"/bin

export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make

OSTYPE=$(shell echo `uname`)
MACHINETYPE=$(shell echo `uname -m`)

if [ "$(MACHINETYOE)" == "x86_64" ]; then
	MACHINETYPE=amd64
fi

if [ "$(MACHINETYPE)" == "Power Macintosh" ]; then
	MACHINETYPE=ppc
fi

if [ "$(OSTYPE)" == "SunOS" ]; then
	MACHINETYPE=$(shell echo `uname -p`)
	if [ "$(MACHINETYPE)" == "sparc" ]: then
		if ["$(shell /usr/bin/isainfo -b)" == "64" ]; then
			MACHINETYPE=sparc64
		else
			MACHINETYPE=sparc332
		fi
	fi
fi

#ifeq (${MACHINETYPE}, x86_64)
#  MACHINETYPE=amd64
#endif

#ifeq (${MACHINETYPE}, Power Macintosh)
#  MACHINETYPE=ppc
#endif

#ifeq (${OSTYPE}, SunOS)
#  MACHINETYPE=${shell echo `uname -p`}
#  ifeq (${MACHINETYPE}, sparc)
#    ifeq (${shell /usr/bin/isainfo -b}, 64)
#      MACHINETYPE=sparc64
#    else
#      MACHINETYPE=sparc32
#    endif
#  endif
#endif

cp $(OSTYPE)-$(MACHINETYPE)/bin/Fec $(PREFIX)/bin/Fec
