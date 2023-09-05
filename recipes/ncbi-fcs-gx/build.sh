#!/bin/bash -e
set -uex

mkdir -vp ${PREFIX}/bin

# file is already present and unzipped
# URL='https://ftp.ncbi.nlm.nih.gov/genomes/TOOLS/FCS/releases/0.4.0/gx_conda_0.4.0.zip'
# curl -o gx_conda_0.4.0.zip ${URL}
# unzip  -u  -o gx_conda_0.4.0.zip
# rm gx_conda_0.4.0.zip

chmod ua+x ./gx
mv ./gx ${PREFIX}/bin/
mv ./blast_names_mapping.tsv ${PREFIX}/bin/
mv ./db_exclude.locs.tsv  ${PREFIX}/bin/
mv ./classify_taxonomy.py ${PREFIX}/bin/
mv ./action_report.py     ${PREFIX}/bin/
mv ./run_gx.py            ${PREFIX}/bin/
mv ./sync_files.py        ${PREFIX}/bin/

# not installing the docker runners
# chmod ua+x ${PREFIX}/bin/run_fcsgx.py
# chmod ua+x ${PREFIX}/bin/run_fcsadaptor.sh

