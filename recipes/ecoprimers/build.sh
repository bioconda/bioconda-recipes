#!/bin/bash

cd ecoPrimers || true
cd src
make -e

install -d "${PREFIX}/bin"
install ecoPrimers "${PREFIX}/bin/"
