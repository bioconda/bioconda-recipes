#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R {bin,database,example,galaxy,lib,LICENSE} ${outdir}/
#Set up links for 
for f in ${outdir}/bin/*; do
    ln -s ${f} ${PREFIX}/bin
done

#Activate/Deactivate dir
ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
mkdir -p $ACTIVATE_DIR
mkdir -p $DEACTIVATE_DIR
cp $RECIPE_DIR/scripts/deactivate.sh $DEACTIVATE_DIR/${PKG_NAME}-deactivate.sh
#Create activate.sh script
echo > "${ACTIVATE_DIR}/${PKG_NAME}-activate.sh" <<EOF
#!/bin/bash
export NGSPLOT="${outdir}"
export _CONDA_SET_NGSPLOT_ENV=1
EOF

#Patch ngs.plot.R to use proper path
sed -i "s#^progpath.*#progpath=$outdir#g" ${outdir}/bin/ngs.plot.r