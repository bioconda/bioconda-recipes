#!/bin/bash
set -eu -o pipefail
make CC=$CC CPP=$CXX F77=$F77

mkdir -p ${PREFIX}/bin
cp gfmix ${PREFIX}/bin
cp treecns ${PREFIX}/bin
cp rert ${PREFIX}/bin
cp alpha_est_mix_rt ${PREFIX}/bin
chmod 755 ${PREFIX}/bin/*

GFMIX_SHARE="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p ${GFMIX_SHARE}
cp *.dat ${GFMIX_SHARE}/

mkdir -p ${PREFIX}/etc/conda/activate.d
cat > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh <<EOF
#!/bin/bash

if [ -d "~/.gfmix " ]; then rm -rf ~/.gfmix ; fi
mkdir -p ~/.gfmix 
cp ${GFMIX_SHARE}/*.dat ~/.gfmix 
EOF

mkdir -p ${PREFIX}/etc/conda/deactivate.d
cat > ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh <<EOF
#!/bin/bash

if [ -d "~/.gfmix " ]; then rm -rf ~/.gfmix ; fi
EOF
