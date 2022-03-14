#!/bin/bash

set -exo pipefail

mkdir -p $PREFIX/etc/conda/activate.d/
echo "export JBROWSE_SOURCE_DIR=$PREFIX/opt/jbrowse" > $PREFIX/etc/conda/activate.d/jbrowse-sourcedir.sh
chmod a+x $PREFIX/etc/conda/activate.d/jbrowse-sourcedir.sh

mkdir -p $PREFIX/etc/conda/deactivate.d/
echo "unset JBROWSE_SOURCE_DIR" > $PREFIX/etc/conda/deactivate.d/jbrowse-sourcedir.sh
chmod a+x $PREFIX/etc/conda/deactivate.d/jbrowse-sourcedir.sh

cd $SRC_DIR

# Doing a full setup as we need to include some plugins, because it's not possible yet to load them at runtime
# See https://github.com/GMOD/jbrowse/issues/1288
# When/If this issue is fixed, we should get back to a quicker install from pre-compiled package:
# see https://github.com/bioconda/bioconda-recipes/tree/a2fc63ddb0a762e49c22255ff6916d7704ebd65c/recipes/jbrowse

# Add BlastView plugin
git clone https://github.com/TAMU-CPT/blastview.git plugins/BlastView/
echo "[ plugins.BlastView ]" >> jbrowse.conf
echo "location = ../plugin/BlastView/" >> jbrowse.conf

# Add GCContent plugin
git clone https://github.com/elsiklab/gccontent.git plugins/GCContent/
echo "[ plugins.GCContent ]" >> jbrowse.conf
echo "location = ../plugin/GCContent/" >> jbrowse.conf

# Add ComboTrackSelector plugin
git clone https://github.com/Arabidopsis-Information-Portal/ComboTrackSelector.git plugins/ComboTrackSelector/
echo "[ plugins.ComboTrackSelector ]" >> jbrowse.conf
echo "location = ../plugin/ComboTrackSelector/" >> jbrowse.conf

# Add MultiBigWig plugin
git clone https://github.com/elsiklab/multibigwig.git plugins/MultiBigWig/
echo "[ plugins.MultiBigWig ]" >> jbrowse.conf
echo "location = ../plugin/MultiBigWig/" >> jbrowse.conf

# Add bookmarks plugin
git clone https://github.com/TAMU-CPT/bookmarks-jbrowse.git plugins/bookmarks/
echo "[ plugins.bookmarks ]" >> jbrowse.conf
echo "location = ../plugin/bookmarks/" >> jbrowse.conf

# Add MAFViewer plugin
git clone https://github.com/cmdcolin/mafviewer.git plugins/MAFViewer
echo "[ plugins.MAFViewer ]" >> jbrowse.conf
echo "location = ../plugin/MAFViewer/" >> jbrowse.conf

# Add NeatFeatures tracktypes
echo "[ plugins.NeatCanvasFeatures ]" >> jbrowse.conf
echo "location = ../plugin/NeatCanvasFeatures/" >> jbrowse.conf
echo "[ plugins.NeatHTMLFeatures ]" >> jbrowse.conf
echo "location = ../plugin/NeatHTMLFeatures/" >> jbrowse.conf

# For cpanm on osx
export HOME=/tmp

./setup.sh

# Remove temp dirs
rm -rf node_modules/ browser/ build/ css/ extlib/ tests/ utils/ website/ setup.log
rm -rf plugins/MultiBigWig/test/

mkdir -p $PREFIX/bin/
cp bin/*.pl $PREFIX/bin/
chmod a+x $PREFIX/bin/*.pl
sed -i.bak 's|../src/perl5|../opt/jbrowse/src/perl5|g' $PREFIX/bin/*.pl
rm $PREFIX/bin/*.pl.bak

mkdir -p $PREFIX/opt/jbrowse/
cp -r * $PREFIX/opt/jbrowse/

if [ ! -f "$PREFIX/opt/jbrowse/dist/main.bundle.js" ]; then
    echo "$PREFIX/opt/jbrowse/dist/main.bundle.js not found, something went bad during the build." >&2
    exit 1
fi
