#!/bin/bash
set -e 
set -x
cd $PREFIX
wget https://www.dropbox.com/s/pq7wsjx61sp8ghm/annotations.tar.gz
tar -xzvf annotations.tar.gz
rm annotations.tar.gz
