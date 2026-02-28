#!/bin/bash

# Exit on any error
set -ex

# Define variables for directories
# define kmc directory  

KMC_DIR="src/kmc3"

mkdir $KMC_DIR/bin
cp $BUILD_PREFIX/bin/kmc* $KMC_DIR/bin/
cp $BUILD_PREFIX/lib/libkmc_core.a $KMC_DIR/bin/

# Build seqtk
SEQTK_DIR="src/seqtk"
cd "$SEQTK_DIR"

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make CC=${CC} CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" all -j "${CPU_COUNT}"

# Go back to the src directory
cd ..

# Compile readskmercount as an object first if it doesn't have a main
${CXX}  -c readskmercount.opt.parameter.cpp -I./kmc3

# Then link it to create the executable
${CXX}  -o readskmercount readskmercount.opt.parameter.o -L./kmc3/bin -lkmc_core -pthread

# Copy everything to the Conda environments bin directory to ensure they're accessible
echo "Copying binaries to PREFIX..."
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/bin/kmc3
mkdir -p $PREFIX/bin/seqtk

for file in *.pl; do
  sed -i.bak '1 s|^#!/usr/bin/perl$|#!/usr/bin/env perl|' "$file"
done
sed -i.bak '1i #!/usr/bin/env perl' html2repeatbed.pl

for file in *.r; do
  sed -i.bak '1i#!/usr/bin/env Rscript' "$file"
done


cp graph.plot.r readskmercount TIPP.pl TIPP_polish.pl html2repeatbed.pl MSA.plot.r TIPP_plastid.pl TIPP_telomere_backup.pl readskmercount.cpp telomeres.visulization.r asm_defaults.cfg asm_hifi.cfg TIPP_plastid.v2.1.pl TIPP_telomere.pl TIPPo.v2.4.pl TIPPo.v2.3.pl TIPPo.v2.2.pl "$PREFIX/bin/" || { echo "Failed to copy specific binaries to PREFIX"; exit 1; }
cp -r kmc3/bin $PREFIX/bin/kmc3/
cp seqtk/seqtk $PREFIX/bin/seqtk/

echo "Installation completed successfully."
echo "Copying activation and deactivation scripts..."
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d

# Add TIPP and related tools to the PATH

cat << EOF > $PREFIX/etc/conda/activate.d/tipp.sh
# Set the current path to the conda environment's bin directory
export CURRENT_PATH=\$CONDA_PREFIX/bin

# Add TIPP and related tools to the PATH
export PATH=\$CURRENT_PATH:\$PATH
export PATH=\$CURRENT_PATH/seqtk:\$PATH
export PATH=\$CURRENT_PATH/kmc3/bin:\$PATH
EOF

cat << EOF > $PREFIX/etc/conda/deactivate.d/tipp.sh
# Remove the current conda environment's bin directory from PATH
export PATH=\$(echo \$PATH | sed -e "s|$CONDA_PREFIX/bin:||g")
EOF

echo "Installation completed successfully."
