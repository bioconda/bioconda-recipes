#!/bin/bash

export CFLAGS="${CFLAGS} -fcommon"
make
install -d "${PREFIX}/bin"
install SweepFinder2 "${PREFIX}/bin/"
