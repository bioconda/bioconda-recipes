#!/bin/bash

cd src

autoreconf -fi
./configure --prefix="${PREFIX}"
make all mpis
# Manual install since `make install` wants to install man pages into non-existent path.
install -d "${PREFIX}/bin"
install migrate-n migrate-n-mpi "${PREFIX}/bin/"
# make install
