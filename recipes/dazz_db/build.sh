#!/bin/bash

mkdir -p "${PREFIX}/bin"
make
make install DEST_DIR="${PREFIX}/bin/"
