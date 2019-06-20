#!/bin/bash

IGBLAST_ADDRESS=ftp://ftp.ncbi.nih.gov/blast/executables/igblast/release
SHARE_DIR=$PREFIX/share/igblast

wget $IGBLAST_ADDRESS/edit_imgt_file.pl
# replace the first line with /usr/bin/env perl instead of the hard-coded /opt
# does this require an explicit perl dependency? 
sed -i.backup '1 s/^.*$/#!\/usr\/bin\/env perl/g' edit_imgt_file.pl
chmod +x edit_imgt_file.pl
mv edit_imgt_file.pl bin/

mkdir -p $PREFIX/bin
mkdir -p $SHARE_DIR/bin

for FILE in makeblastdb edit_imgt_file.pl; do
    cp -f bin/$FILE $PREFIX/bin/
done

for FILE in igblastn igblastp; do
    cp -f bin/$FILE $SHARE_DIR/bin/
done

cp -f $RECIPE_DIR/igblastn.sh $PREFIX/bin/igblastn
sed 's/igblastn/igblastp/g' $PREFIX/bin/igblastn > $PREFIX/bin/igblastp
chmod +x $PREFIX/bin/igblastn $PREFIX/bin/igblastp

for IGBLAST_DIR in internal_data optional_file; do
    mkdir -p $SHARE_DIR/$IGBLAST_DIR
    wget -r -nH --cut-dirs=5 -P $SHARE_DIR/$IGBLAST_DIR $IGBLAST_ADDRESS/$IGBLAST_DIR
    for CVS_FILE in Entries Repository Root; do
        rm -f $SHARE_DIR/$IGBLAST_DIR/$CVS_FILE
    done
done
