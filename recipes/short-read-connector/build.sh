#!/bin/bash

mkdir -p ${PREFIX}/bin

# decrease RAM needed
sed -i.bak 's/make -j/make -j1/' INSTALL
sed -i.bak 's/2> log_linker_err//' test/simple_test.sh

# change run_discoSnp++.sh deps path
sed -i.bak 's|\$EDIR/bin|\$EDIR|' short_read_connector_linker.sh
sed -i.bak 's|\$EDIR/bin|\$EDIR|' short_read_connector_counter.sh

# remove precompiled binary for dsk
sed -i.bak 's|\$EDIR/thirdparty/dsk/bin/linux/dsk|dsk|' short_read_connector_linker.sh
sed -i.bak 's|\$EDIR/thirdparty/dsk/bin/macosx/dsk|dsk|' short_read_connector_linker.sh
# comment out chmod command for precompiled binary for dsk
sed -i.bak 's/^chmod/# chmod/' short_read_connector_linker.sh

# remove precompiled binary for dsk
sed -i.bak 's|\$EDIR/thirdparty/dsk/bin/linux/dsk|dsk|' short_read_connector_counter.sh
sed -i.bak 's|\$EDIR/thirdparty/dsk/bin/macosx/dsk|dsk|' short_read_connector_counter.sh
# comment out chmod command for precompiled binary for dsk
sed -i.bak 's/^chmod/# chmod/' short_read_connector_counter.sh

# installation
sh INSTALL

# copy binaries
cp short_read_connector_counter.sh ${PREFIX}/bin
cp short_read_connector_linker.sh ${PREFIX}/bin

# apply permissions for pipeline
chmod +x ${PREFIX}/bin/short_read_connector_linker.sh
chmod +x ${PREFIX}/bin/short_read_connector_counter.sh

# copy external bin
cp build/bin/* ${PREFIX}/bin
