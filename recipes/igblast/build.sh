#!/bin/bash
set -euo pipefail

IGBLAST_ADDRESS=ftp://ftp.ncbi.nih.gov/blast/executables/igblast/release
SHARE_DIR=$PREFIX/share/igblast

mkdir -p $PREFIX/bin

if [ $(uname) == Linux ]; then
  # The binaries want libbz2.so.1, but the correct soname is libbz2.so.1.0
  for name in makeblastdb igblastn igblastp; do
    patchelf --replace-needed libbz2.so.1 libbz2.so.1.0 bin/$name
  done
fi

# $SHARE_DIR contains the actual igblastn and igblastp binaries and also the
# required data files. Wrappers will be installed into $PREFIX/bin that set
# $IGDATA to point to those data files.
mkdir -p $SHARE_DIR/bin

# Copy binaries and wrappers
for name in igblastn igblastp; do
  mv bin/$name $SHARE_DIR/bin/
  sed "s/igblastn/$name/g" $RECIPE_DIR/igblastn.sh > $PREFIX/bin/$name
  chmod +x $PREFIX/bin/$name
done

# No wrapper needed
mv bin/makeblastdb $PREFIX/bin/

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
    wget -nv -r -nH --cut-dirs=5 -X Entries,Repository,Root,CVS -P $SHARE_DIR/$IGBLAST_DIR $IGBLAST_ADDRESS/$IGBLAST_DIR
done
