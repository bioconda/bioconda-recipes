#!/bin/bash

uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')

ifeq ($(uname_S),Darwin)
make -j${CPU_COUNT}
else
make -j${CPU_COUNT} LEIDEN=true
endif

install -d "${PREFIX}/bin"
install clusty "${PREFIX}/bin"
