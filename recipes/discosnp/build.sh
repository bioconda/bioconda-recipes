#!/bin/bash


export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib
export LIBRARY_PATH=${PREFIX}/lib

mkdir -p ${PREFIX}/bin

# decrease RAM needed
sed -i.bak 's/make -j8/make -j1/' INSTALL

# remove tests because of too much RAM needed
sed -i.bak 's/. .\/simple_test\.sh/#. .\/simple_test\.sh/' INSTALL

# installation
sh INSTALL

# change run_discoSnp++.sh deps path
sed -i.bak 's|\$EDIR/bin|\$EDIR|' run_discoSnp++.sh
sed -i.bak 's|scripts/|../scripts/|' run_discoSnp++.sh
sed -i.bak 's|\$EDIR/bin|\$EDIR|' run_discoSnp++_ML.sh
sed -i.bak 's|\$EDIR/bin|\$EDIR|' run_discoSnp++_storagefile.sh

# copy binaries
cp *.sh ${PREFIX}/bin

# apply permissions for pipeline
chmod +x ${PREFIX}/bin/*.sh

cp build/ext/gatb-core/bin/dbgh5 ${PREFIX}/bin
cp build/bin/read_file_names ${PREFIX}/bin
cp build/bin/kissnp2 ${PREFIX}/bin
cp build/bin/kissreads2 ${PREFIX}/bin
cp build/bin/quick_hierarchical_clustering ${PREFIX}/bin

# copy scripts directory
cp -R scripts ${PREFIX}

# apply exec permissions
chmod +x ${PREFIX}/scripts/*.sh
