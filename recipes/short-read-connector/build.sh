#!/bin/bash

mkdir -p ${PREFIX}/bin

# decrease RAM needed
sed -i.bak 's/make -j/make -j1/' INSTALL

# installation
sh INSTALL

# change run_discoSnp++.sh deps path
sed -i.bak 's/\$EDIR\/bin/\$EDIR/' short_read_connector.sh

# copy dsk binary
if [[ $(uname) == "Darwin" ]]; then
	echo "Configuring for OSX..."
    cp thirdparty/dsk/bin/macosx/dsk ${PREFIX}/bin
    sed -i.bak 's/\$EDIR\/thirdparty\/dsk\/bin\/macosx\/dsk/\$EDIR\/dsk/' short_read_connector.sh
else
    echo "Configuring for Linux..."
    cp thirdparty/dsk/bin/linux/dsk ${PREFIX}/bin
    sed -i.bak 's/\$EDIR\/thirdparty\/dsk\/bin\/linux\/dsk/\$EDIR\/dsk/' short_read_connector.sh
fi

# copy binaries
cp short_read_connector.sh ${PREFIX}/bin

# apply permissions for pipeline
chmod +x ${PREFIX}/bin/short_read_connector.sh

# copy external bin
cp build/bin/* ${PREFIX}/bin
