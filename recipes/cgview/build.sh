#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
sed -i.bak 's|^#!/usr/bin/perl|#!/usr/bin/env perl|'  cgview_xml_builder/cgview_xml_builder.pl
cp -R * $outdir/
cp $RECIPE_DIR/cgview.py $outdir/cgview
ls -l $outdir
ln -s $outdir/cgview $PREFIX/bin
ln -s $outdir/cgview_xml_builder/cgview_xml_builder.pl $PREFIX/bin
chmod 0755 "${PREFIX}/bin/cgview"
chmod 0755 "${PREFIX}/bin/cgview_xml_builder.pl"

