#!/bin/bash

outdir=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
envsubst '${PREFIX}:${PKG_NAME}:${PKG_VERSION}:${PKG_BUILDNUM}' < ${RECIPE_DIR}/response.varfile.template > response.varfile
sh Cytoscape*.sh -q -varfile response.varfile
envsubst '${PREFIX}:${PKG_NAME}:${PKG_VERSION}:${PKG_BUILDNUM}' < ${RECIPE_DIR}/cytoscape.sh.template > $outdir/cytoscape.sh

ln -s $outdir/Cytoscape ${PREFIX}/bin
ln -s $outdir/cytoscape.sh ${PREFIX}/bin
ln -s $outdir/gen_vmoptions.sh ${PREFIX}/bin
