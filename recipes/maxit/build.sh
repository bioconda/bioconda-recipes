#!/bin/bash

export RCSBROOT=${PREFIX}

cd maxit-v10.1/src
sed -i.bak 's|rcsbroot = getenv("RCSBROOT")|rcsbroot = "'${PREFIX}'"|' maxit.C process_entry.C generate_assembly_cif_file.C
cd ../../cifparse-obj-v7.0

sed -i.bak 's/mv /install /' Makefile

make
make binary

install -d ${PREFIX}/bin
install bin/* ${PREFIX}/bin
install -d ${PREFIX}/data
install -m 644 data/* ${PREFIX}/data
