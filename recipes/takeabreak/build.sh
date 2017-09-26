#!/bin/bash

mkdir -p ${PREFIX}/bin

# decrease RAM needed
sed -i.bak 's/make -j4/make -j1/' INSTALL
sed -i.bak 's/.\/build\/bin\/TakeABreak/.\/build\/bin\/TakeABreak -max-memory 1000/' INSTALL

# installation
sh INSTALL

# copy binaries
cp build/bin/TakeABreak ${PREFIX}/bin
