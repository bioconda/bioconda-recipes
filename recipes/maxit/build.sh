#!/bin/sh

export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

cd maxit-v10.1/src
sed -i.bak 's|rcsbroot = getenv("RCSBROOT")|rcsbroot = "${PREFIX}"|' maxit.C process_entry.C generate_assembly_cif_file.C

cd ../cifparse-obj-v7.0
sed -i.bak 's/mv /cp /' Makefile  # circumvent CI errors

cd ../../

make binary
cp -r bin/* ${PREFIX}/bin
cp -r data ${PREFIX}/
