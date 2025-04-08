#!/bin/bash -x

echo "Executing build script"

export LC_ALL="POSIX"

RSAT_DEST="${PREFIX}/share/rsat/"
mkdir -p "${RSAT_DEST}"
mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/public_html"  

# copy folders, scripts and config files to $RSAT_DEST
cp -a LICENSE.txt \
   version.txt \
   perl-scripts \
   python-scripts \
   makefiles \
   R-scripts \
   RSAT_config_default.mk \
   RSAT_config_default.bashrc \
   RSAT_config_default.props \
   RSAT_config_default.conf \
   ${RSAT_DEST}

# place main script in ${PREFIX}/bin and make sure
# required .yaml and .csv files are in relative paths
cp bin/rsat "${PREFIX}/bin/rsat"
cp share/rsat/rsat.yaml "${PREFIX}/share/rsat/rsat.yaml"
cp version.txt "${PREFIX}"
cp public_html/publications.csv "${PREFIX}/public_html"

# build and dispatch compiled binaries
cd contrib
for dbin in info-gibbs count-words matrix-scan-quick compare-matrices-quick retrieve-variation-seq variation-scan
do
    echo "Compiling C/C++ program: $dbin"
    cd "$dbin"
    make clean && make CC=$CC CXX=$CXX && cp "$dbin" "$PREFIX/bin"
    cd ..
done
cd ..

# build local R package required by matrix-clustering (requires -r-base in build:)
echo "Building R package TFBMclust from source"
cd R-scripts
R CMD INSTALL --no-multiarch --with-keep.source TFBMclust
cd ..

# run RSAT configuration script in $RSAT_DEST
echo "Running RSAT configuration in automatic mode"
cd "${RSAT_DEST}"
perl-scripts/configure_rsat.pl -auto \
  rsat_site=conda_rsat \
  rsat_www=auto \
  ucsc_tools=0 \
  ensembl_tools=0 \
  mail_supported=no \
  variations_tools=0 \
  LOGO_PROGRAM=weblogo
