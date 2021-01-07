#!/bin/bash

printenv > /project/maizegdb/sagnik/FINDER/whatsprefix
cd "${SRC_DIR}/src/olego/"
make
cd "${SRC_DIR}/src/assemblies_psiclass_modified/"
make 
cd "${SRC_DIR}/src"
chmod -R a+x *
mkdir -p "${PREFIX}/bin/scripts"
mkdir -p "${PREFIX}/src"
cp "${SRC_DIR}/finder" "${PREFIX}/bin"
cp "${SRC_DIR}/scripts/"* "${PREFIX}/bin/scripts"
#cp "${SRC_DIR}/src/"* "${PREFIX}/src/"
#ls -lhrt $PREFIX/bin > /project/maizegdb/sagnik/FINDER/prefix_bin
ls -lhrt "${PREFIX}/bin/scripts" > /project/maizegdb/sagnik/FINDER/prefix_bin
