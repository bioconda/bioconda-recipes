#!/bin/bash

make
install -d "${PREFIX}/bin"
make install DEST_DIR="${PREFIX}/bin/"
