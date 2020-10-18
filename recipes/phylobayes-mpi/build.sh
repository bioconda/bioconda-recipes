#!/bin/bash
set -euxo pipefail

cd $SRC_DIR/sources
make

cp ${SRC_DIR}/data/pb_mpi ${PREFIX}/bin/
cp ${SRC_DIR}/data/readpb_mpi ${PREFIX}/bin/
cp ${SRC_DIR}/data/tracecomp ${PREFIX}/bin/
cp ${SRC_DIR}/data/bpcomp ${PREFIX}/bin/
cp ${SRC_DIR}/data/cvrep ${PREFIX}/bin/

