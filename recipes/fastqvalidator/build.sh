#!/bin/bash

ls ${SRC_DIR}/libStatGen

export CFLAGS="-I${PREFIX}/include -I${SRC_DIR}/libStatGen/include"
export LDFLAGS="-L${PREFIX}/lib"
export CPATH=${PREFIX}/include:${SRC_DIR}/libStatGen/include

# paths for fastqvalidator
export LIB_PATH_GENERAL=${SRC_DIR}/libStatGen/
export LIB_PATH_FASTQ_VALIDATOR=${SRC_DIR}/libStatGen/

# compile libstatgen
cd libStatGen
make
cp libStatGen*.a ${PREFIX}/lib
cp include/* ${PREFIX}/include
cd ..

# compile fastqvalidator
cd fastQValidator
make
cp bin/fastQValidator ${PREFIX}/bin
