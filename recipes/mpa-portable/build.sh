#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/mpa-portable.py $outdir/mpa-portable
ln -s $outdir/mpa-portable $PREFIX/bin
chmod 0755 "${PREFIX}/bin/mpa-portable"

# overwrite the precompiled binaries for comet and sirius
# that are shipped with mpa-portable by links to the binaries
# of the conda packages (could theoretically be done as well
# for msgf_plus, but the version seems older than the oldest
# available in bioconda .. also its java and therefore does not
# create problems with missing libraries
# see https://github.com/compomics/meta-proteome-analyzer/issues/31)

ln -sf $(which comet.exe)  "$outdir/built/Comet/linux/comet.exe"; 
ln -sf "$(which xtandem)" "$outdir"'/built/X!Tandem/linux/linux_64bit/tandem'
rm -rf "$(which xtandem)" "$outdir"'/built/X!Tandem/linux/linux_32bit/'
