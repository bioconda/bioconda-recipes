#!/bin/bash

# Execute tool with dummy file to trigger the creation of motus_data folder
touch dummy.fq
chmod +x mOTUs.pl
perl ./mOTUs.pl dummy.fq 2> /dev/null || true

# Check files
if [ ! -f motus_data/bin/2bwt-builder -o ! -f motus_data/bin/fastq_trim_filter_v5_EMBL -o ! -f motus_data/bin/fastx_quality_stats -o ! -f motus_data/bin/msamtools -o ! -f motus_data/bin/soap2.21 ]
then
   echo "Binaries not found" 
   exit 1
fi

# Remove blob from the script
sed -i "/__DATA__/q" mOTUs.pl

# Creates a symbolic link from opt/ to bin/ because of the motus_data folder which contains some binaries (from blob text in the file)
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/motus/
cp -r mOTUs.pl motus_data $PREFIX/opt/motus/
ln -s $PREFIX/opt/motus/mOTUs.pl $PREFIX/bin/