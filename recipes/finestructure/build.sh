#!/bin/bash

mkdir -p $PREFIX/bin

if [[ "$OSTYPE" == "darwin"* ]];then
  mv fs_mac_clang $PREFIX/bin/fs
fi
if [[ "$OSTYPE" == "linux-gnu"* ]];then
  mv fs_linux_glibc2.3 $PREFIX/bin/fs
fi

# support scripts
cp *.pl *.R finestructuregreedy.sh $PREFIX/bin/