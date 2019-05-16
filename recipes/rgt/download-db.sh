#!/usr/bin/env bash

echo "Downloading RGT database to ${RGTDATA}..."

# RGTDATA is defined in build.sh, store the db there

# download data from release
wget ${DOWNLOAD_URL} -O RGT.tar.gz
mkdir RGT
tar xf RGT.tar.gz -C RGT --strip-components 1
cp -r RGT/data/fig/ ${RGTDATA}
cp -r RGT/data/fp_hmms/ ${RGTDATA}
cp -r RGT/data/motifs/ ${RGTDATA}
cp -r RGT/data/hg19/ ${RGTDATA}
cp -r RGT/data/hg38/ ${RGTDATA}
cp -r RGT/data/mm9/ ${RGTDATA}
cp -r RGT/data/mm10/ ${RGTDATA}
cp -r RGT/data/zv9/ ${RGTDATA}
cp -r RGT/data/zv10 ${RGTDATA}
rm -rf RGT
rm RGT.tar.gz

cd ${RGTDATA}

# download Genomic Data
setupGenomicData.py --all
setupGenomicData.py --hg19-rm
setupGenomicData.py --hg38-rm
setupGenomicData.py --mm9-rm

# download Logo Data
setupLogoData.py --all

echo "RGT database is downloaded."

exit 0
