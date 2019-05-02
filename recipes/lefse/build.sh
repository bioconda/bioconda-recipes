#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir

cp -R * $outdir
chmod +x $outdir/run_lefse.py
chmod +x $outdir/format_input.py
chmod +x $outdir/lefse2circlader.py
chmod +x $outdir/plot_cladogram.py
chmod +x $outdir/plot_features.py
chmod +x $outdir/plot_res.py
chmod +x $outdir/qiime2lefse.py

ln -s $outdir/run_lefse.py $PREFIX/bin
ln -s $outdir/format_input.py $PREFIX/bin/lefse-format_input.py
ln -s $outdir/lefse2circlader.py $PREFIX/bin
ln -s $outdir/plot_cladogram.py $PREFIX/bin/lefse-plot_cladogram.py
ln -s $outdir/plot_features.py $PREFIX/bin/lefse-plot_features.py
ln -s $outdir/plot_res.py $PREFIX/bin/lefse-plot_res.py
ln -s $outdir/qiime2lefse.py $PREFIX/bin
