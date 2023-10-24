#!/bin/bash

mkdir -p "${PREFIX}/bin"
make PATH_HDF5="${PREFIX}" DEST_DIR="${PREFIX}/bin/"
make install DEST_DIR="${PREFIX}/bin/"
