#! /bin/bash

#compile
cd $SRC_DIR/
pwd
cmake -DHASH_MAP=USE_TSL_ROBIN_MAP -DCMAKE_CXX_FLAGS="-O3" -DCMAKE_INSTALL_PREFIX=${PREFIX} ${SRC_DIR}
make -j${CPU_COUNT} ${VERBOSE_CM} 
make install -j${CPU_COUNT}

