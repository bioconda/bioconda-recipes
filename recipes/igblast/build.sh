#!/bin/bash

IGBLAST_ADDRESS=ftp://ftp.ncbi.nih.gov/blast/executables/igblast/release
INCLUDE_DIR=$PREFIX/include/igblast

wget $IGBLAST_ADDRESS/edit_imgt_file.pl
sed -i '1 s/^.*$/#!\/usr\/bin\/env perl/g' edit_imgt_file.pl # replace the first line with /usr/bin/env perl instead of the hard-coded /opt
chmod +x edit_imgt_file.pl
mv edit_imgt_file.pl bin/

mkdir -p $PREFIX/bin
mkdir -p $INCLUDE_DIR

for FILE in igblastn igblastp makeblastdb edit_imgt_file.pl; do
    cp -f bin/$FILE $PREFIX/bin/
done

for IGBLAST_DIR in internal_data optional_file; do
    mkdir -p $INCLUDE_DIR/$IGBLAST_DIR
    wget -r -np -nd -P $INCLUDE_DIR/$IGBLAST_DIR $IGBLAST_ADDRESS/$IGBLAST_DIR
    for CVS_FILE in Entries Repository Root; do
        rm -f $INCLUDE_DIR/$IGBLAST_DIR/$CVS_FILE
    done
done

ACTIVATE_SCRIPT=$PREFIX/etc/conda/activate.d/igblast_vars.sh
DEACTIVATE_SCRIPT=$PREFIX/etc/conda/deactivate.d/igblast_vars.sh

for SCRIPT in $ACTIVATE_SCRIPT $DEACTIVATE_SCRIPT; do
    mkdir -p $(dirname "$SCRIPT")
    if [[ $SCRIPT == $ACTIVATE_SCRIPT ]]; then
        echo "export IGDATA=\$CONDA_ENV_PATH/include/igblast" > $SCRIPT
    else
        echo "unset IGDATA" > $SCRIPT
    fi
done
