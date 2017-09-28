#!/bin/bash

mkdir -p ${PREFIX}/bin

# decrease RAM needed
sed -i.bak 's/make -j/make -j1/' compile_all_tools.sh

# installation
/bin/bash compile_all_tools.sh

# copy binaries
cp run_mapsembler2_pipeline.sh ${PREFIX}/bin
chmod +x ${PREFIX}/bin/run_mapsembler2_pipeline.sh

# copy directories
cp -R tools ${PREFIX}
