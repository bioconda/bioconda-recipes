#!/bin/bash

for platform in illumina 454 SOLiD;
do
    cp art_${platform} $PREFIX/bin
done
