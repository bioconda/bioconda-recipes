#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/mpa-server.py $outdir/mpa-server
ln -s $outdir/mpa-server $PREFIX/bin

# mysql
sql_data_dir=$outdir/mysql
mkdir -p $sql_data_dir
mysqld --initialize-insecure --datadir $sql_data_dir
# start mysqld
nohup mysqld --datadir $sql_data_dir &
sql_daemon_pid=$!
mysql -u root --execute="create database mpa_server;"
mysql -u root --database="mpa_server" < $outdir/mpa_zip/init/MPA_Init_Database.sql
# stop mysqld
kill -TERM $sql_daemon_pid

cat <<EOF > config_LINUX.properties
# mpa-server configuration
apptitle=MetaProteomeAnalyzer

default_qvalue_accepted=0.05
default_fdr=0.05

# sql
sqlDataDir=/home/hennings/Projects/bioconda-recipes/recipes/mpa-server/mysql
srvAddress=localhost
dbAddress=localhost
dbName=mpa_server
dbUsername=root
dbPass=
app.port=9000
xampp_path=

# paths
base_path=/home/hennings/Projects/bioconda-recipes/recipes/mpa-server/mpa_zip

# all paths are relative to base_path
path.transfer=/data/transfer/
path.blastdb=UP_SwissProt_Nov2016.fasta

# fasta files
path.fasta=/data/fasta/
file.fastalist=fasta_list.txt
fasta.formater.path=fastaformat.sh

# search engines
path.xtandem=/software/xtandem_linux/bin/
path.xtandem.output=/data/output/xtandem/
app.xtandem=tandem.exe
path.omssa.output=/data/output/omssa/
path.omssa=/software/omssa
app.omssa=omssacl

# percolator
path.qvality=/software/percolator_linux/
app.qvality=qvality

# blast
blast.makeblastdb=/software/blast_linux/bin/makeblastdb
blast.file=/software/blast_linux/bin/blastp
EOF
