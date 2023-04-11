#! /bin/bash

#create directory following bioconda rules
ipk_dir="${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}"
mkdir -p $ipk_dir

#compile
cd $SRC_DIR
pwd
cmake -DHASH_MAP=USE_TSL_ROBIN_MAP -DCMAKE_CXX_FLAGS="-O3" ..
make -j4

