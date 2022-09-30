#!/usr/bin/env bash
make clean
make

INSTALL_DIR="$CONDA_PREFIX/share/SeMeta-1.0"

mkdir -p "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/database" # https://ftp.ncbi.nih.gov/blast/db/FASTA/nr.gz
mkdir -p "$INSTALL_DIR/taxonomy" # https://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz

cp SeMeta_Assign "$INSTALL_DIR"
cp SeMeta_Cluster "$INSTALL_DIR"
cp config.conf "$INSTALL_DIR"
cp README.txt "$INSTALL_DIR"

# set up 'config.conf'
echo "$CONDA_PREFIX/bin/" > "$INSTALL_DIR/config.conf"
echo "$INSTALL_DIR/database/" >> "$INSTALL_DIR/config.conf"

ln -s "$INSTALL_DIR/SeMeta_Cluster" "$CONDA_PREFIX/bin/"
ln -s "$INSTALL_DIR/SeMeta_Assign" "$CONDA_PREFIX/bin/"
ln -s "$INSTALL_DIR/config.conf" "$CONDA_PREFIX/bin/"
ln -s "$INSTALL_DIR/taxonomy" "$CONDA_PREFIX/bin/"
