#!/bin/bash


#cp -R gtpython/gt ${PREFIX}/lib/python${CONDA_PY:0:1}.${CONDA_PY:1:2}/site-packages/

#sed -i.bak "s/DEPLIBS:=/DEPLIBS:=-lsupc++ /g" Makefile

#make -n > log.txt 
#grep "lsupc++" log.txt

#sed -i.bak 's/^\#include "md5.h"/#include <openssl\/md5.h>/' src/core/md5_fingerprint.c

#sed -i.bak 's/^\#include "md5.h"/#include <openssl\/md5.h>/' src/extended/md5set.c

#sed -i.bak 's/\(^\#include "extended\/reverse_api.h"\)/\1\nvoid md5 (const char *message, long len, char *output);/' src/extended/md5set.c

#sed -i.bak 's/\(^struct GtR {\)/int luaopen_md5_core (lua_State *L);\n\1/' src/gtr.c






make
export prefix=$PREFIX
make install 

cd gtpython
$PYTHON setup.py install

