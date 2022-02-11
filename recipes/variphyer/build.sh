#!/bin/bash

#Add into PATH
export PATH="${PREFIX}/bin:$PATH"

# define and make a src folder
VARIPHYER=${PREFIX}/share/${PKG_NAME}
PHYLO_PROGRAMS=${PREFIX}/share/phylo_programs

mkdir -p ${VARIPHYER}
mkdir -p ${PHYLO_PROGRAMS}

bzip2 -d phylo_programs/stripSubsetLCBs.bz2
cp -r ./phylo_programs/stripSubsetLCBs ${PHYLO_PROGRAMS}

# copy everything into src folder
cp -r ./* ${VARIPHYER}

#copy external source to the share dir
tar zxvf ${VARIPHYER}/phylo_programs/BEASTGen_v1.0.2.tgz
cp -r ./BEASTGen_v1.0.2 ${PHYLO_PROGRAMS}
rm -r BEASTGen_v1.0.2

chmod 777 ${VARIPHYER}/vaphy
chmod 777 ${PHYLO_PROGRAMS}/BEASTGen_v1.0.2/bin/beastgen
chmod 777 ${PHYLO_PROGRAMS}/stripSubsetLCBs

#make a bin folder
mkdir -p ${PREFIX}/bin 

ln -s ${VARIPHYER}/vaphy ${PREFIX}/bin/vaphy
ln -s ${VARIPHYER}/main.nf ${PREFIX}/bin/main.nf
ln -s ${PHYLO_PROGRAMS}/BEASTGen_v1.0.2/bin/beastgen ${PREFIX}/bin/beastgen
ln -s ${PHYLO_PROGRAMS}/stripSubsetLCBs ${PREFIX}/bin/stripSubsetLCBs