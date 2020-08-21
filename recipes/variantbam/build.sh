#!/bin/bash
./configure --prefix=$PREFIX
make
install -d "${PREFIX}/bin"
install src/variant "${PREFIX}/bin/"
