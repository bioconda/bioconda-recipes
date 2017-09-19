#!/bin/bash

mkdir -p $PREFIX/bin/
cp $SRC_DIR/group_humann2_uniref_abundances_to_GO.sh $PREFIX/bin/
chmod +x $PREFIX/bin/group_humann2_uniref_abundances_to_GO.sh

cp -r $SRC_DIR/src $PREFIX/bin/src
chmod +x $PREFIX/bin/src/group_humann2_uniref_abundances_to_GO_download_datasets.sh

