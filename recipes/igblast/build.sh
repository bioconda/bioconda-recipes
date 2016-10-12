#!/bin/bash
set -euo pipefail

IGBLAST_ADDRESS=ftp://ftp.ncbi.nih.gov/blast/executables/igblast/release
SHARE_DIR=$PREFIX/share/igblast

wget $IGBLAST_ADDRESS/edit_imgt_file.pl
# replace the first line with /usr/bin/env perl instead of the hard-coded /opt
sed -i.backup '1 s/^.*$/#!\/usr\/bin\/env perl/g' edit_imgt_file.pl
chmod +x edit_imgt_file.pl
mv edit_imgt_file.pl bin/

mkdir -p $PREFIX/bin
mkdir -p $SHARE_DIR/bin

if [ $(uname) == Linux ]; then
    # Distributed IgBLAST 1.5.0 binaries set an RPATH that conda build complains build.
    for FILE in makeblastdb igblastn igblastp; do
        patchelf --remove-rpath bin/$FILE
    done
fi

for FILE in makeblastdb edit_imgt_file.pl; do
    mv bin/$FILE $PREFIX/bin/
done

for FILE in igblastn igblastp; do
    mv bin/$FILE $SHARE_DIR/bin/
done

cp -f $RECIPE_DIR/igblastn.sh $PREFIX/bin/igblastn
sed 's/igblastn/igblastp/g' $PREFIX/bin/igblastn > $PREFIX/bin/igblastp
chmod +x $PREFIX/bin/igblastn $PREFIX/bin/igblastp

for IGBLAST_DIR in internal_data optional_file; do
    mkdir -p $SHARE_DIR/$IGBLAST_DIR
    wget -nv -r -nH --cut-dirs=5 -X Entries,Repository,Root -P $SHARE_DIR/$IGBLAST_DIR $IGBLAST_ADDRESS/$IGBLAST_DIR
done
