# this script creates the file with configuration paths to the metaWRAP modules.
mv bin/config-metawrap bin/configmetawrap
echo "#!/usr/bin/env bash" > bin/configmetawrap
echo "# Paths to metaWRAP scripts (dont have to modify)" >> bin/configmetawrap
echo 'mw_path=$(which metawrap)' >> bin/configmetawrap
echo 'bin_path=${mw_path%/*}' >> bin/configmetawrap
echo 'SOFT=${bin_path}/metawrap-scripts' >> bin/configmetawrap
echo 'PIPES=${bin_path}/metawrap-modules' >> bin/configmetawrap
echo '' >> bin/configmetawrap

echo "# CONFIGURABLE PATHS FOR DATABASES (see 'Databases' section of metaWRAP README for details)" >> bin/configmetawrap
echo "# path to kraken standard database" >> bin/configmetawrap
echo "KRAKEN_DB=~/KRAKEN_DB" >> bin/configmetawrap
echo "" >> bin/configmetawrap

echo "# path to indexed human (or other host) genome (see metaWRAP website for guide). This includes .bitmask and .srprism files"  >> bin/configmetawrap
echo "BMTAGGER_DB=~/BMTAGGER_DB" >> bin/configmetawrap
echo "" >> bin/configmetawrap

echo "# paths to BLAST databases" >> bin/configmetawrap
echo "BLASTDB=~/NCBI_NT_DB" >> bin/configmetawrap
echo "TAXDUMP=~/NCBI_TAX_DB" >> bin/configmetawrap

# copying over all necessary files
mkdir -p ${PREFIX}/bin/
cp -ar bin/* ${PREFIX}/bin/

#conda 23.7.4 loading environment variables not recognizing config-metawrap
sed -i 's/config-metawrap/configmetawrap/g' ${PREFIX}/bin/metawrap
sed -i 's/config-metawrap/configmetawrap/g' ${PREFIX}/bin/metawrap-modules/*.sh
sed -i 's/config-metawrap/configmetawrap/g' ${PREFIX}/bin/metawrap-scripts/*.sh

chmod +x ${PREFIX}/bin/*
