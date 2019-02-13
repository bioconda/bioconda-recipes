#!/bin/bash

mkdir -p ${PREFIX}/bin

# installation
/bin/bash compile_all_tools.sh


# sed PATH_TOOLS
sed -i.bak 's/PATH_TOOLS="\.\/tools\/"/PATH_TOOLS=""/' run_mapsembler2_pipeline.sh

# copy run_mapsembler2_pipeline
cp run_mapsembler2_pipeline.sh ${PREFIX}/bin
chmod +x ${PREFIX}/bin/run_mapsembler2_pipeline.sh

#copy dependencies
cp -R tools/* ${PREFIX}/bin
