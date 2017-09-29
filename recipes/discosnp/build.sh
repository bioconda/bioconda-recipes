#!/bin/bash

mkdir -p ${PREFIX}/bin

# decrease RAM needed
sed -i.bak 's/make -j8/make -j1/' INSTALL

# remove tests because of too much RAM needed
sed -i.bak 's/. .\/simple_test\.sh/#. .\/simple_test\.sh/' INSTALL

# installation
sh INSTALL

# copy binaries
cp run_discoSnp++.sh ${PREFIX}/bin
chmod +x ${PREFIX}/bin/run_discoSnp++.sh

# copy directories
cp -R tools ${PREFIX}
cp -R build ${PREFIX}
cp -R scripts ${PREFIX}
