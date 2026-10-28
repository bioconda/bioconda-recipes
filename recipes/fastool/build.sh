#!/bin/bash

set -xe

make -j ${CPU_COUNT} CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
install fastool "${PREFIX}/bin/"
