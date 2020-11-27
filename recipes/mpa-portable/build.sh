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
# of the conda packages (could theoreticallt be done also 
# for msgf_plus, but the version seems older than the oldest
# available in bioconda .. see issue below)

# note when mpa write the input xml files to the folder containing
# the (x)tandem binary (resp. link). this may fail for multi user
# installations and containerized deployments (as well as other
# read only deployments)
# see https://github.com/compomics/meta-proteome-analyzer/issues/31

# possible workaround: 
# 
# jar_dir=$(mpa-portable -get_jar_dir)
# cp -R $jar_dir/conf .
# cp -r "$jar_dir" .
# local_jar_dir="$(basename $jar_dir)"
# ln -sf "$jar_dir"'/built/X!Tandem/linux/linux_64bit/tandem' "$local_jar_dir"'/built/X!Tandem/linux/linux_64bit/tandem' &&
# ln -sf "\$jar_dir"'/built/Comet/linux/comet.exe' "\$local_jar_dir"'/built/Comet/linux/comet.exe' &&
# 
# "$local_jar_dir"/mpa-portable de.mpa.cli.CmdLineInterface ....

if [ -f "$outdir/built/Comet/linux/comet.exe" ]; then
    ln -sf $(which comet.exe)  "$outdir/built/Comet/linux/comet.exe"; 
fi

for i in 32 64; do
    ln -sf "$(which xtandem)" "$outdir"'/built/X!Tandem/linux/linux_'"$i""bit/tandem"
done
