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

# write config file
cat <<EOF > "$outdir"/config_LINUX.properties.template
# mpa-server configuration
apptitle=MetaProteomeAnalyzer

default_qvalue_accepted=0.05
default_fdr=0.05

# all paths are relative to base_path
base_path=
path.transfer=/data/transfer/
path.blastdb=uniprot_sp_March_2020.fasta

# sql
sqlDataDir=$sql_subdir
srvAddress=localhost
dbAddress=localhost
dbName=mpa_server
dbUsername=root
dbPass=
app.port=9000
xampp_path=

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
