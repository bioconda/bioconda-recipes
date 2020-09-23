#!/bin/bash

# in v1.0 we need to 
# - remove CC=gcc, 
# - add -lpthread
# - make CFLAGS not overwrite globally set CFLAGS
# - and add a missing include to a .h file (needed for osx build)
sed -i -e 's/^CC=.*//; s/-lm/-lm -lpthread/; s/CFLAGS=/CFLAGS+=/;' src/Makefile
sed -i -e '/^#include "structs.h"/a \
#include <pthread.h>' src/commonFunctions.h

make -C src/ all
cp -r bin/ "$PREFIX"
