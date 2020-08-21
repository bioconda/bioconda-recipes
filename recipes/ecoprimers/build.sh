#!/bin/bash

cd ecoPrimers/src
make -e

install -d "${PREFIX}/bin"
install ecoPrimers "${PREFIX}/bin/"
