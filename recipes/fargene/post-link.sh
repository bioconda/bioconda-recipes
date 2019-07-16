#!/bin/bash

wget ftp://ftp.ncbi.nlm.nih.gov/genomes/TOOLS/ORFfinder/linux-i64/ORFfinder.gz

gunzip ORFfinder.gz

chmod +x ORFfinder 

mv ORFfinder ${PREFIX}/bin
