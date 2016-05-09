#!/bin/bash
git clone --recursive https://github.com/ekg/glia.git && \
cd glia && \
make && \
chmod 755 ./glia

mkdir -p $PREFIX/bin
cp glia $PREFIX/bin


