echo "# Paths to custon pipelines and scripts of metaWRAP" > bin/config-metawrap

echo 'mw_path=$(which metawrap)' >> bin/config-metawrap
echo 'bin_path=${mw_path%/*}' >> bin/config-metawrap
echo 'SOFT=${bin_path}/metawrap-scripts' >> bin/config-metawrap
echo 'PIPES=${bin_path}/metawrap-modules' >> bin/config-metawrap
echo '' >> bin/config-metawrap

echo "# OPTIONAL databases (see 'Databases' section of metaWRAP README for details)" >> bin/config-metawrap
echo "# path to kraken standard database" >> bin/config-metawrap
echo "KRAKEN_DB=/path/to/database" >> bin/config-metawrap
echo "" >> bin/config-metawrap

echo "# path to indexed human genome (see metaWRAP website for guide). This insludes files hg38.bitmask and hg38.srprism.*"  >> bin/config-metawrap
echo "BMTAGGER_DB=/path/to/database" >> bin/config-metawrap
echo "" >> bin/config-metawrap

echo "# paths to BLAST databases" >> bin/config-metawrap
echo "BLASTDB=/path/to/database/NCBI_nt" >> bin/config-metawrap
echo "TAXDUMP=/path/to/database/NCBI_tax" >> bin/config-metawrap

chmod +x bin/config-metawrap


# copying over all necessary files
mkdir -p $PREFIX/bin/
cp bin/metaWRAP $PREFIX/bin/
cp bin/metawrap $PREFIX/bin/
cp bin/config-metawrap $PREFIX/bin/
cp -r bin/metawrap-modules $PREFIX/bin/
cp -r bin/metawrap-scripts $PREFIX/bin/
