#!/bin/bash

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
	${SRC_DIR} 

make -j${CPU_COUNT} ${VERBOSE_CM} 
make install -j${CPU_COUNT}