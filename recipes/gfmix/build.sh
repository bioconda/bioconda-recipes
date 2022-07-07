#!/bin/bash
set -eu -o pipefail
make CC=$CC CPP=$CXX F77=$F77

mkdir -p ${PREFIX}/bin
cp gfmix ${PREFIX}/bin
cp treecns ${PREFIX}/bin
cp rert ${PREFIX}/bin
cp alpha_est_mix_rt ${PREFIX}/bin

mkdir -p ${PREFIX}/gfmix
cp *dat ${PREFIX}/gfmix

mkdir -p ${PREFIX}/etc/conda/activate.d
cat > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh <<EOF
#!/bin/bash

if [ -d "$HOME/.gfmix " ]; then rm -Rf $HOME/.gfmix ; fi
mkdir -p $HOME/.gfmix 
cp ${PREFIX}/bin/*.dat $HOME/.gfmix 
EOF

mkdir -p ${PREFIX}/etc/conda/deactivate.d
cat > ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh <<EOF
#!/bin/bash

if [ -d "$HOME/.gfmix " ]; then rm -Rf $HOME/.gfmix ; fi
EOF
