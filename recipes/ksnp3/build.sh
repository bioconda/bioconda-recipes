#!/bin/bash
mkdir -p ${PREFIX}/bin

# Copy files
ls -lha ./
chmod 775 ./kSNP3/*
rm ./kSNP4/.DS_Store
cp ./kSNP3/* ${PREFIX}/bin
