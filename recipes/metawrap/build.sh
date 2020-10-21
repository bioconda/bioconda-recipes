# this script creates the file with configuration paths to the metaWRAP modules.
echo "# Paths to metaWRAP scripts (dont have to modify)" > bin/config-metawrap
echo 'mw_path=$(which metawrap)' >> bin/config-metawrap
echo 'bin_path=${mw_path%/*}' >> bin/config-metawrap
echo 'SOFT=${bin_path}/metawrap-scripts' >> bin/config-metawrap
echo 'PIPES=${bin_path}/metawrap-modules' >> bin/config-metawrap
echo '' >> bin/config-metawrap

echo "# CONFIGURABLE PATHS FOR DATABASES (see 'Databases' section of metaWRAP README for details)" >> bin/config-metawrap
echo "# path to kraken standard database" >> bin/config-metawrap
echo "KRAKEN_DB=~/KRAKEN_DB" >> bin/config-metawrap
echo "" >> bin/config-metawrap

echo "# path to indexed human (or other host) genome (see metaWRAP website for guide). This includes .bitmask and .srprism files"  >> bin/config-metawrap
echo "BMTAGGER_DB=~/BMTAGGER_DB" >> bin/config-metawrap
echo "" >> bin/config-metawrap

echo "# paths to BLAST databases" >> bin/config-metawrap
echo "BLASTDB=~/NCBI_NT_DB" >> bin/config-metawrap
echo "TAXDUMP=~/NCBI_TAX_DB" >> bin/config-metawrap

chmod +x bin/config-metawrap


# copying over all necessary files
mkdir -p $PREFIX/bin/
cp bin/metaWRAP $PREFIX/bin/
cp bin/metawrap $PREFIX/bin/
cp bin/config-metawrap $PREFIX/bin/
cp -r bin/metawrap-modules $PREFIX/bin/
cp -r bin/metawrap-scripts $PREFIX/bin/
