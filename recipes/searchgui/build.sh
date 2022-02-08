#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/searchgui.py $outdir/searchgui
ls -l $outdir
ln -s $outdir/searchgui $PREFIX/bin
chmod 0755 "${PREFIX}/bin/searchgui"

# removing xtandem prebuilt binaries and replacing them by xtandem package ones
rm -f "$outdir"'/resources/XTandem/linux/linux_64bit/tandem'
ln -sf "$(which xtandem)" "$outdir"'/resources/XTandem/linux/linux_64bit/tandem'

# replacing all metamorpheus stuff included in the source package by the one provided by MetaMorpheus Conda package
# specific folders and files provided by the source package will be kept
cp -TR "$(command -v metamorpheus | xargs dirname | xargs dirname)/lib/dotnet/tools/metamorpheus/" "$outdir"'/resources/MetaMorpheus/'
ln -sf "$(which metamorpheus)" "$outdir"'/resources/MetaMorpheus/metamorpheus'

# removing makeblast prebuilt binary and replacing it by blast package ones
rm -f "$outdir"'/resources/makeblastdb/linux/linux_64bit/makeblastdb'
ln -sf "$(which makeblastdb)" "$outdir"'/resources/makeblastdb/linux/linux_64bit/makeblastdb'

# removing MsAmanda prebuilt binary for macosx until .NET Core 6 is released
rm -f "$outdir"'/resources/MS Amanda/osx/'*
