#!/bin/bash

mkdir -p ${PREFIX}/bin

# decrease RAM needed
sed -i.bak 's/make -j8/make -j1/' INSTALL

# remove tests because of too much RAM needed
sed -i.bak 's/. .\/simple_test\.sh/#. .\/simple_test\.sh/' INSTALL

# installation
sh INSTALL

# change run_discoSnp++.sh deps path
sed -i.bak 's/\$EDIR\/bin/\$EDIR/' run_discoSnp++.sh
sed -i.bak 's/scripts\//..\/scripts\//' run_discoSnp++.sh

# copy binaries
cp run_discoSnp++.sh ${PREFIX}/bin
chmod +x ${PREFIX}/bin/run_discoSnp++.sh

cp build/ext/gatb-core/bin/dbgh5 ${PREFIX}/bin
cp build/bin/read_file_names ${PREFIX}/bin
cp build/bin/kissnp2 ${PREFIX}/bin
cp build/bin/kissreads2 ${PREFIX}/bin

# copy scripts directory
cp -R scripts ${PREFIX}
