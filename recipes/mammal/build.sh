#!/bin/bash
set -eu -o pipefail
make CC=$CC CPP=$CXX F77=$F77

mkdir -p ${PREFIX}/bin
cp mammal ${PREFIX}/bin
cp mammal-sigma ${PREFIX}/bin
cp mult-data ${PREFIX}/bin
cp mult-mix-lwt ${PREFIX}/bin
cp charfreq ${PREFIX}/bin
cp dgpe ${PREFIX}/bin
chmod 755 ${PREFIX}/bin/*

MAMMAL_SHARE="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p ${MAMMAL_SHARE}
cp *.dat ${MAMMAL_SHARE}/

mkdir -p ${PREFIX}/etc/conda/activate.d
cat > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh <<EOF
#!/bin/bash

if [ -d "~/.mammal " ]; then rm -rf ~/.mammal ; fi
mkdir -p ~/.mammal 
cp ${MAMMAL_SHARE}/*.dat ~/.mammal 
EOF

mkdir -p ${PREFIX}/etc/conda/deactivate.d
cat > ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh <<EOF
#!/bin/bash

if [ -d "~/.mammal " ]; then rm -rf ~/.mammal ; fi
EOF
