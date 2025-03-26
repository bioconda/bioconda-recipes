#!/bin/bash -x

echo "Executing build script"

# RSAT_DEST="$PREFIX/opt/rsat/"
BASE=`pwd`
RSAT_DEST="$PREFIX/share/rsat"
mkdir -p "$RSAT_DEST"
mkdir -p "$PREFIX/bin"
## mkdir -p "$PREFIX/share/rsat"
## mkdir -p "$PREFIX/public_html"

mkdir -p "$PREFIX/share/rsat/public_html"
#mkdir -p "$CONDA_PREFIX/public_html"




cp -a LICENSE.txt \
   perl-scripts \
   python-scripts \
   makefiles \
   R-scripts \
   public_html \
   RSAT_config_default.mk \
   RSAT_config_default.bashrc \
   RSAT_config_default.props \
   RSAT_config_default.conf \
   "$RSAT_DEST"

echo "Executing copy scripts"

cp bin/rsat $PREFIX/bin/rsat
echo "Path: $(pwd)"
echo "Prefix: $PREFIX)"
echo "cp bin/rsat $PREFIX/bin/rsat"
cp version.txt $PREFIX/version.txt
echo "cp version.txt $PREFIX/bin/version.txt"
cp version.txt $PREFIX/bin/version.txt
cp version.txt $CONDA_PREFIX/version.txt
cp version.txt $CONDA_PREFIX/../version.txt
cp version.txt $RSAT_DEST/version.txt
mkdir $PREFIX/public_html
mkdir $CONDA_PREFIX/public_html
cp public_html/publications.csv $PREFIX/public_html/publications.csv
cp public_html/publications.csv $CONDA_PREFIX/public_html/publications.csv
cp public_html/publications.csv $RSAT_DEST/public_html/publications.csv
cp share/rsat/rsat.yaml $PREFIX/share/rsat/rsat.yaml

# Build and dispatch compiled binaries
cd contrib
for dbin in info-gibbs count-words matrix-scan-quick compare-matrices-quick retrieve-variation-seq variation-scan
do
    echo "Compiling C/C++ program: $dbin"
    cd "$dbin"
    make clean && make CC=$CC CXX=$CXX && cp "$dbin" "$PREFIX/bin"
    cd ..
done
cd ..

# Build the R package with RSAT functions used by matrix-clustering
echo "Building R package TFBMclust"
cd R-scripts
R CMD INSTALL --no-multiarch --with-keep.source TFBMclust
cd ..


# Run the configuration script
echo "Running RSAT configuration in automatic mode"
cd $RSAT_DEST
perl-scripts/configure_rsat.pl -auto \
  rsat_site=conda_rsat \
  rsat_www=auto \
  ucsc_tools=1 \
  ensembl_tools=1 \
  LOGO_PROGRAM=weblogo
cd $BASE
