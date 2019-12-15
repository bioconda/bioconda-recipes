#!/bin/bash

make prefix=${PREFIX} CC=${CC} AR=${AR} RANLIB=${RANLIB} CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" install
