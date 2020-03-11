#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p "$outdir"
mkdir -p "$PREFIX"/bin
cp -R * "$outdir"/
cp "$RECIPE_DIR"/mpa-server.py "$outdir"/mpa-server
ln -s "$outdir"/mpa-server "$PREFIX"/bin

# mysql
sql_subdir=mysql
sql_data_dir=$outdir/$sql_subdir
mkdir -p "$sql_data_dir"
mysqld --initialize-insecure --datadir $sql_data_dir

# start mysqld
nohup mysqld --user="${USER:-root}" --datadir "$sql_data_dir" &
sql_daemon_pid=$!
sleep 3

mysql -u root --execute="create database mpa_server;"
mysql -u root --database="mpa_server" < "$outdir"/init/mysql_minimal_incl_taxonomy.sql

# stop mysqld
kill -TERM $sql_daemon_pid

# write config file
cat <<EOF > "$outdir"/config_LINUX.properties
# mpa-server configuration
apptitle=MetaProteomeAnalyzer

default_qvalue_accepted=0.05
default_fdr=0.05

# sql
sqlDataDir=$sql_subdir
srvAddress=localhost
dbAddress=localhost
dbName=mpa_server
dbUsername=root
dbPass=
app.port=9000
xampp_path=

# paths
base_path=

# all paths are relative to base_path
path.transfer=/data/transfer/
path.blastdb=uniprot_sp_March_2020.fasta

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
