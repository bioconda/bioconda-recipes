#!/bin/bash

mkdir -p ${PREFIX}/bin/
mkdir -p ${PREFIX}/share/ampd-up/
mkdir -p ${PREFIX}/share/ampd-up/src/
mkdir -p ${PREFIX}/share/ampd-up/data/
cp -r src/. ${PREFIX}/share/ampd-up/src/
cp -r data/. ${PREFIX}/share/ampd-up/data/

chmod +x ${PREFIX}/share/ampd-up/src/AMPd-Up.py

echo "#!/bin/bash" > ${PREFIX}/bin/AMPd-Up
echo "${PREFIX}/share/ampd-up/src/AMPd-Up.py \$@" >> ${PREFIX}/bin/AMPd-Up
