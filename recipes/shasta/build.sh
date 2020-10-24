#!/bin/bash

# mkdir shasta-build/
# cd shasta-build/
# cmake ../shasta/
# make all -j
# make install
if [[ "$OSTYPE" == "darwin"* ]];then
  mv shasta-macOS-0.6.0 shasta
fi
if [[ "$OSTYPE" == "linux-gnu"* ]];then
  mv shasta-Linux-0.6.0 shasta
fi

chmod +x shasta
mkdir -p $PREFIX/bin
cp shasta $PREFIX/bin/shasta