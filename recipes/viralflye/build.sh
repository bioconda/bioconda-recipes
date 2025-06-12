#!/bin/bash

exec &>> $PREFIX/.messages.txt

# install viralcomplete from source
curl -o $PREFIX/bin/viralcomplete \
    https://raw.githubusercontent.com/ablab/viralComplete/db9ffa7c1beb38c1375a33619388d4bd4d2be59b/bin/viralcomplete
chmod 755 $PREFIX/bin/viralcomplete

mkdir -p $PREFIX/blast_db
mkdir -p $PREFIX/data

# install viralflye
mv viralflye $SP_DIR/
mv viralFlye.py $PREFIX/bin/
