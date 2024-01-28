#!/bin/bash

exec &>> $PREFIX/.messages.txt

curl -o viralComplete.tar.gz \
  https://codeload.github.com/ablab/viralComplete/tar.gz/db9ffa7

mkdir viralComplete

tar -zxf viralComplete.tar.gz \
  -C viralComplete \
  --strip-components 1

printf "Moving viralcomplete data to %s\n" $PREFIX
mv viralComplete/blast_db $PREFIX/
mv viralComplete/data $PREFIX/

rm -rf viralComplete viralComplete.tar.gz
