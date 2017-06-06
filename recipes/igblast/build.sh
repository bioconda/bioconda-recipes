#!/bin/bash
set -euo pipefail

IGBLAST_ADDRESS=ftp://ftp.ncbi.nih.gov/blast/executables/igblast/release
SHARE_DIR=$PREFIX/share/igblast

mkdir -p $PREFIX/bin

# This is going to contain the igblastn and igblastp binaries.
# Only wrappers are installed into $PREFIX/bin/ .
mkdir -p $SHARE_DIR/bin

if [ $(uname) == Linux ]; then
    # If on Linux, compile the tool ourselves because the distributed binaries
    # link against libbz2.so, and the usual conda bzip2 package does not
    # provide this. See https://github.com/bioconda/bioconda-recipes/pull/3020

    cd c++
    ./configure --prefix=$PREFIX --with-sqlite3=$PREFIX
    make -j2
    mv ReleaseMT/bin/{igblastn,igblastp} $SHARE_DIR/bin/
    mv ReleaseMT/bin/makeblastdb $PREFIX/bin/
else
    # On macOS, use the prebuilt binaries
    mv bin/makeblastdb $PREFIX/bin/
    mv bin/igblastn bin/igblastp $SHARE_DIR/bin/
fi


# Since IgBLAST needs the environment variable IGDATA in order to find its
# data files (download below), the igblastn and igblastp binaries will be
# wrappers that set IGDATA to $SCRIPT_DIR/../share/igblast.
cp -f $RECIPE_DIR/igblastn.sh $PREFIX/bin/igblastn
sed 's/igblastn/igblastp/g' $PREFIX/bin/igblastn > $PREFIX/bin/igblastp
chmod +x $PREFIX/bin/igblastn $PREFIX/bin/igblastp


wget $IGBLAST_ADDRESS/edit_imgt_file.pl
# Replace the hardcoded perl shebang pointing to /opt with `#!/usr/bin/env perl`.
sed -i.backup '1 s_^.*$_#!/usr/bin/env perl_' edit_imgt_file.pl
chmod +x edit_imgt_file.pl
mv edit_imgt_file.pl $PREFIX/bin/


# Download data files necessary to run IgBLAST. These are not included in the
# source or binary distributions.
# See the [IgBLAST README](ftp://ftp.ncbi.nih.gov/blast/executables/igblast/release/README)

for IGBLAST_DIR in internal_data optional_file; do
    mkdir -p $SHARE_DIR/$IGBLAST_DIR
    wget -nv -r -nH --cut-dirs=5 -X Entries,Repository,Root -P $SHARE_DIR/$IGBLAST_DIR $IGBLAST_ADDRESS/$IGBLAST_DIR
done
