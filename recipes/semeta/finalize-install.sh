#!/usr/bin/env bash

#-- check if SeMeta is installed
which SeMeta_Cluster > /dev/null \
  || ( echo " [ERROR] SeMeta is not installed. Abort."; exit 1 )

#-- get target directories
TAXO_DIR=$(dirname $(readlink -f $(which SeMeta_Cluster))"/taxonomy")
DB_DIR=$(dirname $(readlink -f $(which SeMeta_Cluster))"/database")

#-- downlaod, check and uncompress databases

# NCBI taxonomy
pushd "$TAXO_DIR" > /dev/null

wget https://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz.md5
wget https://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz

md5sum -c "$TAXO_DIR/taxdump.tar.gz.md5" \
  && tar zxvf "$TAXO_DIR/taxdump.tar.gz" nodes.dmp names.dmp \
  || ( echo " [ERROR] 'taxdump.tar.gz' is invalid. Abort."; rm "$TAXO_DIR/taxdump.tar.gz*"; exit 3 )

rm "$TAXO_DIR/taxdump.tar.gz"
popd > /dev/null


# NCBI nr
pushd "$DB_DIR" > /dev/null

wget https://ftp.ncbi.nih.gov/blast/db/FASTA/nr.gz.md5
wget https://ftp.ncbi.nih.gov/blast/db/FASTA/nr.gz

md5sum -c "$DB_DIR/nr.gz.md5" \
  && gunzip "$DB_DIR/nr.gz"  \
  || ( echo " [ERROR] 'nr.gz' is invalid. Abort."; rm nr.gz*; exit 2 )

popd > /dev/null
