#!/bin/bash


# move all files to outdir and link into it by bin executor
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
ls -l $outdir
mkdir -p $PREFIX/bin
printf '#!/bin/bash\n' > $PREFIX/bin/run_app.sh
printf 'cd $PREFIX\n' >> $PREFIX/bin/run_app.sh
printf "cd share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM\nR -e \"shiny::runApp(\"./\", port=3838)\"" >> $PREFIX/bin/run_app.sh
#cp $RECIPE_DIR/run_app.sh $outdir/
#ln -s $outdir/run_app.sh $PREFIX/bin
chmod 0755 "${PREFIX}/bin/run_app.sh"


