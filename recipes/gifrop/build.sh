# THIS CHUNK TO SET UP CUSTOM ABRICATE DBs #

# extract abricate db filepath
DATADIR=$(abricate 2>&1 >/dev/null | grep 'datadir' | sed -E 's/.*folder \[(.*)\]./\1/')
echo $DATADIR

mkdir "$DATADIR"/megares2
mkdir "$DATADIR"/viroseqs

gunzip ./db/abricate_megares_reduced.fasta.gz
gunzip ./db/viroseqs_90.fasta.gz

cp $SRC_DIR/db/abricate_megares_reduced.fasta "$DATADIR"/megares2/sequences
cp $SRC_DIR/db/viroseqs_90.fasta "$DATADIR"/viroseqs/sequences

abricate --setupdb

# END ABRICATE DB SETUP #


# THIS CHUNK TO MOVE SCRIPTS TO BIN #

cp -r ./* $PREFIX/bin/
