#!/bin/bash


cat <<EOF >> ${PREFIX}/.messages.txt

######################################
# First time usage please README !!! #
######################################

The databases are huge and consequently not shiped within this installation. 
Please download and install the Databases manually by following the commands below:
!!! /!\ Edit the 2 first lines to match the wished version of the DB /!\ !!!

Commands:
=========
# See here for latest db available: https://github.com/ebi-pf-team/interproscan or http://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/
# Set version
version_major=5.54
version_minor=87.0

# get the md5 of the databases
wget http://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/${version_major}-${version_minor}/interproscan-${version_major}-${version_minor}-64-bit.tar.gz.md5
# get the databases (with core because much faster to download)
wget http://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/${version_major}-${version_minor}/interproscan-${version_major}-${version_minor}-64-bit.tar.gz   
# checksum
md5sum -c interproscan-${version_major}-${version_minor}-64-bit.tar.gz.md5
# untar gz
tar xvzf interproscan-${version_major}-${version_minor}-64-bit.tar.gz
# remove old DB
rm -rf $CONDA_PREFIX/share/InterProScan/data/
# copy past the new db
cp -r interproscan-${version_major}-${version_minor}/data $CONDA_PREFIX/share/InterProScan/


INFO:
====
Phobius (licensed software), SignalP, SMART (licensed components) and TMHMM use 
licensed code and data provided by third parties. If you wish to run these 
analyses it will be necessary for you to obtain a licence from the vendor and 
configure your local InterProScan installation to use them. 
(see more information in $CONDA_PREFIX/share/InterProScan/data/<db>)



EOF
