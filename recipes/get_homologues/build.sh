#!/bin/bash

mkdir -p $PREFIX/bin

if [[ $(uname -s) == Darwin ]]; then
        cp macosx/get_homologues-* $PREFIX/bin/
else
        cp x86_64/get_homologues-* $PREFIX/bin/
fi

### install in opt/
#mkdir -p $PREFIX/opt/
#find $SRC_DIR/util -name '*.pl' -exec sed -i.bak 's/FindBin::Bin/FindBin::RealBin/' {} +
#find $SRC_DIR/util -name '*.bak' -exec rm {} +
#cp -R $SRC_DIR $PREFIX/opt/$PKG_NAME
#
## symlink to binaries
#mkdir -p $PREFIX/bin/
#ln -s $PREFIX/opt/$PKG_NAME/TransDecoder.Predict $PREFIX/bin/
#ln -s $PREFIX/opt/$PKG_NAME/TransDecoder.LongOrfs $PREFIX/bin/
#ln -s $PREFIX/opt/$PKG_NAME/util/*.pl $PREFIX/bin/




# RSAT_DEST="$PREFIX/opt/rsat/"
#BASE=`pwd`
#RSAT_DEST="$PREFIX/share/rsat/"
#mkdir -p "$RSAT_DEST"
#mkdir -p "$PREFIX/bin"
## mkdir -p "$PREFIX/share/rsat"
#cp -a LICENSE.txt \
#   perl-scripts \
#   python-scripts \
#   makefiles \
#   R-scripts \
#   RSAT_config_default.mk \
#   RSAT_config_default.bashrc \
#   RSAT_config_default.props \
#   RSAT_config_default.conf \
#   "$RSAT_DEST"

#cp bin/rsat $PREFIX/bin/rsat
#cp share/rsat/rsat.yaml $PREFIX/share/rsat/rsat.yaml

# Build the R package with RSAT functions used by matrix-clustering
#echo "Building R package TFBMclust"
#cd R-scripts
#R CMD INSTALL --no-multiarch --with-keep.source TFBMclust
#cd ..


# Run the configuration script
#echo "Running RSAT configuration in automatic mode"
#cd $RSAT_DEST
#perl-scripts/configure_rsat.pl -auto \
#  rsat_site=conda_rsat \
#  rsat_www=auto \
#  ucsc_tools=1 \
#  ensembl_tools=1 \
#  LOGO_PROGRAM=weblogo
#cd $BASE

